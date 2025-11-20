class ForecastService
  def initialize(user)
    @user = user
  end

  def generate_forecast(horizon_months = 12)
    # Get historical transaction data
    transactions = @user.transactions.where("date >= ?", 12.months.ago).order(date: :asc)

    if transactions.empty?
      return { success: false, error: "No transaction data available for forecasting" }
    end

    # Calculate monthly net savings
    monthly_data = calculate_monthly_net_savings(transactions)

    if monthly_data.empty?
      return { success: false, error: "Insufficient data for forecasting" }
    end

    # Prepare data for Python ML service
    net_savings_history = monthly_data.values

    # Call Python ML service
    ml_result = call_ml_service(net_savings_history, horizon_months)

    unless ml_result[:success]
      return ml_result
    end

    # Calculate starting balance (current balance based on transactions)
    starting_balance = calculate_current_balance(transactions)

    # Create forecast record
    forecast = @user.forecasts.create!(
      forecast_horizon_months: horizon_months,
      starting_balance: starting_balance,
      predicted_monthly_net_savings: ml_result[:predicted_net_savings],
      generated_at: Time.current
    )

    {
      success: true,
      forecast: forecast,
      predictions: ml_result[:predicted_net_savings],
      starting_balance: starting_balance
    }
  rescue => e
    { success: false, error: "Forecast generation failed: #{e.message}" }
  end

  private

  def calculate_monthly_net_savings(transactions)
    # Group by month and calculate net savings
    monthly_groups = transactions.group_by { |t| t.date.beginning_of_month }

    monthly_data = {}
    monthly_groups.each do |month, trans|
      income = trans.select(&:income?).sum(&:amount)
      expenses = trans.select(&:expense?).sum { |t| t.amount.abs }
      net = income - expenses
      monthly_data[month] = net
    end

    monthly_data.sort.to_h
  end

  def calculate_current_balance(transactions)
    # Calculate net balance from all transactions
    income = transactions.select(&:income?).sum(&:amount)
    expenses = transactions.select(&:expense?).sum { |t| t.amount.abs }
    income - expenses
  end

  def call_ml_service(net_savings_history, forecast_horizon)
    # Path to Python script
    python_script = Rails.root.join('ml_service', 'forecast.py')
    python_venv = Rails.root.join('ml_service', 'venv', 'bin', 'python3')

    # Prepare input JSON
    input_data = {
      net_savings: net_savings_history,
      forecast_horizon: forecast_horizon,
      method: 'linear'
    }

    # Call Python script
    begin
      output, status = Open3.capture2(
        python_venv.to_s,
        python_script.to_s,
        stdin_data: input_data.to_json,
        binmode: true
      )

      result = JSON.parse(output, symbolize_names: true)

      if result[:success]
        result
      else
        { success: false, error: result[:error] || "ML service error" }
      end
    rescue JSON::ParserError => e
      { success: false, error: "Failed to parse ML service response: #{e.message}" }
    rescue => e
      { success: false, error: "ML service call failed: #{e.message}" }
    end
  end
end
