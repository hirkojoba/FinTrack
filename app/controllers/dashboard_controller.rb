class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user

    # Get transactions for the last 12 months
    @transactions = current_user.transactions.where("date >= ?", 12.months.ago).order(date: :asc)

    # Calculate monthly summaries
    @monthly_data = calculate_monthly_data(@transactions)

    # Calculate category breakdown for expenses
    @category_data = calculate_category_breakdown(@transactions)

    # Calculate overall statistics
    @stats = calculate_statistics(@transactions)

    # Get the most recent forecast
    @forecast = current_user.forecasts.recent.first
  end

  def generate_forecast
    service = ForecastService.new(current_user)
    result = service.generate_forecast(12)

    if result[:success]
      redirect_to dashboard_path, notice: "Forecast generated successfully!"
    else
      redirect_to dashboard_path, alert: "Failed to generate forecast: #{result[:error]}"
    end
  end

  def simulate_scenario
    # Security: Ensure forecast belongs to current user
    forecast = current_user.forecasts.recent.first

    unless forecast
      render json: { success: false, error: "No forecast available" }, status: :unprocessable_entity
      return
    end

    # Security: Validate input parameters
    extra_savings = params[:extra_monthly_savings].to_f
    expense_reduction = params[:expense_reduction_percent].to_f

    if extra_savings < 0 || extra_savings > 10000
      render json: { success: false, error: "Invalid extra savings amount" }, status: :unprocessable_entity
      return
    end

    if expense_reduction < 0 || expense_reduction > 100
      render json: { success: false, error: "Invalid expense reduction percentage" }, status: :unprocessable_entity
      return
    end

    service = ScenarioService.new(forecast)
    result = service.simulate(
      extra_monthly_savings: extra_savings,
      expense_reduction_percent: expense_reduction
    )

    if result[:success]
      # Calculate cumulative balances for charting
      baseline_balance = forecast.starting_balance
      scenario_balance = forecast.starting_balance

      baseline_balances = result[:baseline_predictions].map do |savings|
        baseline_balance += savings
        baseline_balance.round(2)
      end

      scenario_balances = result[:adjusted_predictions].map do |savings|
        scenario_balance += savings
        scenario_balance.round(2)
      end

      render json: {
        success: true,
        baseline_balances: baseline_balances,
        scenario_balances: scenario_balances,
        baseline_final: baseline_balances.last,
        scenario_final: scenario_balances.last,
        total_impact: result[:total_impact]
      }
    else
      render json: result, status: :unprocessable_entity
    end
  end

  def generate_ai_insights
    # Security: Rate limiting - allow AI insights generation once per minute
    last_generation_time = session[:last_ai_generation_time]
    if last_generation_time && Time.parse(last_generation_time) > 1.minute.ago
      redirect_to dashboard_path, alert: "Please wait before generating new AI insights. Try again in a moment."
      return
    end

    forecast = current_user.forecasts.recent.first

    unless forecast
      redirect_to dashboard_path, alert: "Please generate a forecast first to get AI insights."
      return
    end

    # Check if scenario parameters are provided
    scenario_data = nil
    if params[:extra_monthly_savings].present? || params[:expense_reduction_percent].present?
      # Security: Validate input parameters
      extra_savings = params[:extra_monthly_savings].to_f
      expense_reduction = params[:expense_reduction_percent].to_f

      if extra_savings < 0 || extra_savings > 10000 || expense_reduction < 0 || expense_reduction > 100
        redirect_to dashboard_path, alert: "Invalid scenario parameters."
        return
      end

      service = ScenarioService.new(forecast)
      scenario_result = service.simulate(
        extra_monthly_savings: extra_savings,
        expense_reduction_percent: expense_reduction
      )

      if scenario_result[:success]
        scenario_data = {
          extra_monthly_savings: extra_savings,
          expense_reduction_percent: expense_reduction,
          adjusted_predictions: scenario_result[:adjusted_predictions]
        }
      end
    end

    # Generate AI explanation
    advice_service = AdviceService.new(current_user, forecast)
    result = advice_service.generate_explanation(scenario: scenario_data)

    if result[:success]
      # Store explanation in session for display
      session[:ai_explanation] = result[:explanation]
      # Update rate limiting timestamp
      session[:last_ai_generation_time] = Time.current.to_s
      redirect_to dashboard_path, notice: "AI insights generated successfully!"
    else
      redirect_to dashboard_path, alert: "Failed to generate AI insights: #{result[:error]}"
    end
  end

  private

  def calculate_monthly_data(transactions)
    # Group transactions by month and calculate totals
    monthly_groups = transactions.group_by { |t| t.date.beginning_of_month }

    monthly_data = {}
    (0..11).each do |i|
      month = i.months.ago.beginning_of_month
      monthly_data[month] = { income: 0, expenses: 0, net: 0 }
    end

    monthly_groups.each do |month, trans|
      income = trans.select(&:income?).sum(&:amount)
      expenses = trans.select(&:expense?).sum { |t| t.amount.abs }
      net = income - expenses

      monthly_data[month] = {
        income: income,
        expenses: expenses,
        net: net
      }
    end

    monthly_data.sort_by { |k, _v| k }.to_h
  end

  def calculate_category_breakdown(transactions)
    # Get only expenses and group by category
    expenses = transactions.select(&:expense?)

    category_totals = expenses.group_by(&:category).transform_values do |trans|
      trans.sum { |t| t.amount.abs }
    end

    category_totals.sort_by { |_k, v| -v }.to_h
  end

  def calculate_statistics(transactions)
    income_transactions = transactions.select(&:income?)
    expense_transactions = transactions.select(&:expense?)

    total_income = income_transactions.sum(&:amount)
    total_expenses = expense_transactions.sum { |t| t.amount.abs }
    net_savings = total_income - total_expenses

    avg_monthly_income = income_transactions.any? ? total_income / 12.0 : 0
    avg_monthly_expenses = expense_transactions.any? ? total_expenses / 12.0 : 0
    avg_monthly_savings = avg_monthly_income - avg_monthly_expenses

    {
      total_income: total_income,
      total_expenses: total_expenses,
      net_savings: net_savings,
      avg_monthly_income: avg_monthly_income,
      avg_monthly_expenses: avg_monthly_expenses,
      avg_monthly_savings: avg_monthly_savings,
      transaction_count: transactions.count
    }
  end
end
