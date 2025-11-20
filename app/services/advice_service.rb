class AdviceService
  def initialize(user, forecast = nil)
    @user = user
    @forecast = forecast || user.forecasts.recent.first
  end

  def generate_explanation(scenario: nil)
    unless @forecast
      return { success: false, error: "No forecast available to generate explanation" }
    end

    # Build context for the LLM
    context = build_context(scenario)

    # Call OpenAI API
    result = call_openai_api(context)

    if result[:success]
      {
        success: true,
        explanation: result[:explanation],
        context_used: context
      }
    else
      result
    end
  rescue => e
    { success: false, error: "Failed to generate explanation: #{e.message}" }
  end

  private

  def build_context(scenario)
    # Calculate statistics from recent transactions
    recent_transactions = @user.transactions.where("date >= ?", 3.months.ago)

    total_income = recent_transactions.select(&:income?).sum(&:amount)
    total_expenses = recent_transactions.select(&:expense?).sum { |t| t.amount.abs }
    avg_monthly_income = total_income / 3.0
    avg_monthly_expenses = total_expenses / 3.0
    avg_monthly_net = avg_monthly_income - avg_monthly_expenses

    # Baseline forecast projection
    baseline_starting = @forecast.starting_balance
    baseline_ending = baseline_starting + @forecast.predicted_monthly_net_savings.sum
    baseline_total_savings = @forecast.predicted_monthly_net_savings.sum

    context = {
      avg_monthly_income: avg_monthly_income.round(2),
      avg_monthly_expenses: avg_monthly_expenses.round(2),
      avg_monthly_net_savings: avg_monthly_net.round(2),
      forecast_horizon: @forecast.forecast_horizon_months,
      baseline_starting_balance: baseline_starting.to_f,
      baseline_ending_balance: baseline_ending.to_f,
      baseline_total_savings: baseline_total_savings.to_f
    }

    # Add scenario data if provided
    if scenario
      scenario_ending = baseline_starting + scenario[:adjusted_predictions].sum
      context.merge!(
        scenario_extra_savings: scenario[:extra_monthly_savings],
        scenario_expense_reduction: scenario[:expense_reduction_percent],
        scenario_ending_balance: scenario_ending,
        scenario_total_savings: scenario[:adjusted_predictions].sum,
        scenario_impact: scenario_ending - baseline_ending
      )
    end

    # Add user goals if set
    if @user.savings_goal_amount && @user.savings_goal_months
      context.merge!(
        savings_goal_amount: @user.savings_goal_amount.to_f,
        savings_goal_months: @user.savings_goal_months
      )
    end

    context
  end

  def call_openai_api(context)
    api_key = ENV['OPENAI_API_KEY']

    unless api_key.present?
      return { success: false, error: "OpenAI API key not configured" }
    end

    # Build the prompt
    prompt = build_prompt(context)

    # Make API call
    response = HTTParty.post(
      'https://api.openai.com/v1/chat/completions',
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{api_key}"
      },
      body: {
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: 'system',
            content: 'You are an educational financial assistant helping users understand their savings projections. Provide clear, encouraging, and educational explanations. Never give investment advice. Always include a disclaimer that this is for educational purposes only.'
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        temperature: 0.7,
        max_tokens: 300
      }.to_json,
      timeout: 30
    )

    if response.success?
      result = JSON.parse(response.body, symbolize_names: true)
      explanation = result.dig(:choices, 0, :message, :content)

      { success: true, explanation: explanation }
    else
      error_message = response.parsed_response&.dig('error', 'message') || 'Unknown error'
      { success: false, error: "OpenAI API error: #{error_message}" }
    end
  rescue HTTParty::Error => e
    { success: false, error: "API request failed: #{e.message}" }
  rescue JSON::ParserError => e
    { success: false, error: "Failed to parse API response: #{e.message}" }
  rescue => e
    { success: false, error: "Unexpected error: #{e.message}" }
  end

  def build_prompt(context)
    prompt = "A user has the following financial data:\n\n"
    prompt += "Average monthly income: $#{context[:avg_monthly_income]}\n"
    prompt += "Average monthly expenses: $#{context[:avg_monthly_expenses]}\n"
    prompt += "Average monthly net savings: $#{context[:avg_monthly_net_savings]}\n\n"

    prompt += "Current forecast (#{context[:forecast_horizon]} months):\n"
    prompt += "- Starting balance: $#{context[:baseline_starting_balance]}\n"
    prompt += "- Projected ending balance: $#{context[:baseline_ending_balance]}\n"
    prompt += "- Expected total savings: $#{context[:baseline_total_savings]}\n\n"

    if context[:scenario_extra_savings] || context[:scenario_expense_reduction]
      prompt += "User is considering changes:\n"
      prompt += "- Extra monthly savings: $#{context[:scenario_extra_savings]}\n" if context[:scenario_extra_savings]
      prompt += "- Expense reduction: #{context[:scenario_expense_reduction]}%\n" if context[:scenario_expense_reduction]
      prompt += "\nWith these changes:\n"
      prompt += "- New projected ending balance: $#{context[:scenario_ending_balance]}\n"
      prompt += "- Impact: $#{context[:scenario_impact]}\n\n"
    end

    if context[:savings_goal_amount]
      prompt += "User's savings goal: $#{context[:savings_goal_amount]} in #{context[:savings_goal_months]} months\n\n"
    end

    prompt += "Provide a brief, encouraging explanation (2-3 paragraphs) of:\n"
    prompt += "1. What the forecast means for the user\n"
    prompt += "2. Whether they're on track for their goals (if set)\n"
    if context[:scenario_impact]
      prompt += "3. How the proposed changes would impact their savings\n"
    end
    prompt += "\nEnd with a one-sentence educational disclaimer."

    prompt
  end
end
