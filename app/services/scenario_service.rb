class ScenarioService
  def initialize(forecast)
    @forecast = forecast
  end

  def simulate(extra_monthly_savings:, expense_reduction_percent:)
    # Get baseline predictions from the forecast
    baseline_predictions = @forecast.predicted_monthly_net_savings

    # Calculate adjusted predictions
    adjusted_predictions = baseline_predictions.map do |baseline_savings|
      # Add extra monthly savings
      adjusted = baseline_savings + extra_monthly_savings.to_f

      # Apply expense reduction (as additional savings)
      # Assuming average monthly expenses can be estimated from historical data
      # For simplicity, we'll treat expense reduction as additional savings
      expense_adjustment = calculate_expense_adjustment(expense_reduction_percent.to_f)
      adjusted += expense_adjustment

      adjusted.round(2)
    end

    {
      success: true,
      adjusted_predictions: adjusted_predictions,
      baseline_predictions: baseline_predictions,
      total_impact: (adjusted_predictions.sum - baseline_predictions.sum).round(2)
    }
  rescue => e
    { success: false, error: "Scenario simulation failed: #{e.message}" }
  end

  def create_scenario(name:, extra_monthly_savings:, expense_reduction_percent:)
    result = simulate(
      extra_monthly_savings: extra_monthly_savings,
      expense_reduction_percent: expense_reduction_percent
    )

    return result unless result[:success]

    scenario = @forecast.scenarios.create!(
      user: @forecast.user,
      name: name || "Scenario #{Time.current.strftime('%Y-%m-%d %H:%M')}",
      extra_monthly_savings: extra_monthly_savings,
      expense_reduction_percent: expense_reduction_percent,
      resulting_predicted_net_savings: result[:adjusted_predictions]
    )

    {
      success: true,
      scenario: scenario,
      **result
    }
  rescue => e
    { success: false, error: "Failed to create scenario: #{e.message}" }
  end

  private

  def calculate_expense_adjustment(reduction_percent)
    return 0 if reduction_percent.zero?

    # Estimate monthly expenses from user's transactions
    user = @forecast.user
    recent_transactions = user.transactions.where("date >= ?", 3.months.ago)

    if recent_transactions.empty?
      return 0
    end

    # Calculate average monthly expenses
    total_expenses = recent_transactions.select(&:expense?).sum { |t| t.amount.abs }
    avg_monthly_expenses = total_expenses / 3.0

    # Calculate savings from expense reduction
    savings_from_reduction = avg_monthly_expenses * (reduction_percent / 100.0)

    savings_from_reduction.round(2)
  end
end
