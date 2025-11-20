# FinTrack - Autonomous Financial Advisor

FinTrack is an educational web application that helps users track their finances, visualize spending patterns, and forecast future savings using machine learning. It provides AI-powered insights to help users understand their financial trajectory.

**IMPORTANT:** FinTrack is an educational tool only and does not provide professional financial advice. Always consult with a qualified financial advisor for personalized financial guidance.

## Features

### Core Features
- **User Authentication**: Secure sign-up and login with Devise
- **Transaction Management**: Track income and expenses with auto-categorization
- **CSV Import**: Bulk upload transactions from CSV files
- **Interactive Dashboard**: Visualize your financial data with charts
- **Financial Forecasting**: ML-powered 12-month savings predictions using linear regression
- **What-If Scenarios**: Simulate the impact of lifestyle changes on your savings
- **AI Insights**: Get natural language explanations of your financial forecast (powered by OpenAI)

### Visualizations
- Monthly net savings trend (line chart)
- Expenses by category breakdown (doughnut chart)
- 12-month savings forecast projection
- Real-time scenario comparison charts

## Tech Stack

### Backend
- **Ruby** 3.2.3
- **Rails** 8.1.1
- **PostgreSQL** 16.10
- **Devise** - Authentication
- **HTTParty** - HTTP requests

### Frontend
- **Chart.js** 4.4.0 - Data visualizations
- **Vanilla JavaScript** - Interactive UI components
- **Embedded Ruby (ERB)** - Templating

### Machine Learning
- **Python** 3.12.3
- **scikit-learn** - Linear regression forecasting
- **NumPy** - Numerical operations

### APIs
- **OpenAI GPT-3.5 Turbo** - AI-generated financial insights

## Prerequisites

- Ruby 3.2.3 or higher
- Rails 8.1.1 or higher
- PostgreSQL 16 or higher
- Python 3.12 or higher
- Node.js (for asset compilation)
- OpenAI API key (for AI insights feature)

## Installation

### 1. Clone the Repository
```bash
cd /path/to/your/projects
git clone <your-repo-url>
cd FinTrack
```

### 2. Install Ruby Dependencies
```bash
# Configure local gem installation (if needed)
bundle config set --local path 'vendor/bundle'

# Install gems
bundle install
```

### 3. Install Python Dependencies
```bash
cd ml_service
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cd ..
```

### 4. Database Setup
```bash
# Start PostgreSQL service
sudo service postgresql start  # Linux
# Or: brew services start postgresql  # macOS

# Create and migrate database
rails db:create
rails db:migrate
```

### 5. Environment Configuration
Create a `.env` file in the project root:
```bash
OPENAI_API_KEY=your_openai_api_key_here
```

**Note:** The `.env` file is already in `.gitignore` to protect your API keys.

### 6. Start the Server
```bash
rails server
```

Visit `http://localhost:3000` in your browser.

## Configuration

### OpenAI API Key
1. Sign up at [OpenAI](https://openai.com/) and get an API key
2. Add it to your `.env` file as shown above
3. The AI insights feature will only work with a valid API key

### Database Configuration
Database settings are in `config/database.yml`. The default configuration uses PostgreSQL.

## Usage

### Getting Started
1. **Sign Up**: Create a new account on the home page
2. **Set Up Profile** (Optional): Navigate to Profile to set monthly income and savings goals
3. **Add Transactions**:
   - Click "Add Transaction" to manually enter transactions
   - Or use "Upload CSV" to bulk import from a CSV file
4. **Generate Forecast**: Once you have transaction data, click "Run Forecast" to generate ML predictions
5. **Explore Scenarios**: Use the sliders to simulate different saving strategies
6. **Get AI Insights**: Click "Get AI Insights" for a natural language explanation of your forecast

### CSV Import Format
Your CSV file should have the following columns:
```csv
date,description,amount,category
2024-01-15,Salary,3000.00,Income
2024-01-16,Groceries,-125.50,Groceries
2024-01-17,Uber Ride,-25.00,Transportation
```

**Notes:**
- Expenses should be negative values
- Income should be positive values
- Category is optional (will auto-categorize if blank)
- Maximum file size: 5MB
- Maximum rows: 10,000

### Auto-Categorization
FinTrack automatically categorizes transactions based on keywords in the description:
- **Transportation**: uber, lyft, taxi, transit, bus, train, metro
- **Eating Out**: starbucks, coffee, restaurant, cafe, food, dining
- **Groceries**: grocery, supermarket, trader joe, whole foods, safeway
- **Housing**: rent, mortgage, lease
- **Utilities**: utility, electric, gas, water, internet, phone
- **Entertainment**: netflix, spotify, hulu, amazon prime, subscription
- **Health & Fitness**: gym, fitness, health, doctor, medical, pharmacy
- **Income**: salary, paycheck, income, wage

## Security Features

### Implemented Security Measures
- **Authentication**: Devise-based user authentication with encrypted passwords
- **Authorization**: All resources scoped to `current_user` - users can only access their own data
- **CSRF Protection**: Rails built-in CSRF tokens on all forms
- **Input Validation**:
  - Strong parameters to prevent mass assignment
  - Server-side validation on all models
  - Client-side HTML5 validation for immediate feedback
  - Range validation on scenario simulation inputs
- **File Upload Security**:
  - File type validation (CSV only)
  - File size limit (5MB)
  - Row count limit (10,000 rows)
- **Rate Limiting**: AI insights generation limited to once per minute per user
- **API Key Protection**: Environment variables stored in `.env` (gitignored)
- **SQL Injection Prevention**: All queries use ActiveRecord parameterization
- **XSS Protection**: Rails auto-escapes output in ERB templates

## Project Structure

```
FinTrack/
├── app/
│   ├── controllers/
│   │   ├── dashboard_controller.rb    # Main dashboard with forecasts
│   │   ├── profiles_controller.rb      # User profile management
│   │   └── transactions_controller.rb  # Transaction CRUD + CSV import
│   ├── models/
│   │   ├── user.rb                    # User model with Devise
│   │   ├── transaction.rb             # Transaction model
│   │   ├── forecast.rb                # ML forecast results
│   │   └── scenario.rb                # What-if scenario data
│   ├── services/
│   │   ├── forecast_service.rb        # ML forecasting integration
│   │   ├── scenario_service.rb        # Scenario simulation logic
│   │   └── advice_service.rb          # OpenAI integration
│   └── views/
│       ├── dashboard/
│       │   └── index.html.erb         # Main dashboard with charts
│       ├── transactions/
│       │   ├── index.html.erb         # Transaction list
│       │   ├── new.html.erb           # Add transaction form
│       │   ├── edit.html.erb          # Edit transaction form
│       │   └── upload.html.erb        # CSV upload form
│       └── profiles/
│           └── edit.html.erb          # Profile settings
├── ml_service/
│   ├── forecast.py                    # Python ML service
│   ├── requirements.txt               # Python dependencies
│   └── venv/                          # Python virtual environment
├── config/
│   ├── routes.rb                      # Application routes
│   └── database.yml                   # Database configuration
├── db/
│   ├── migrate/                       # Database migrations
│   └── schema.rb                      # Database schema
├── .env                               # Environment variables (gitignored)
├── .gitignore                         # Git ignore rules
├── Gemfile                            # Ruby dependencies
└── README.md                          # This file
```

## Machine Learning Details

### Forecasting Algorithm
FinTrack uses **linear regression** to predict future monthly net savings:

1. **Data Preparation**: Calculates net savings (income - expenses) for each month
2. **Model Training**: Fits a linear regression model on historical monthly data
3. **Prediction**: Projects net savings for the next 12 months
4. **Fallback**: If insufficient data or model fails, uses a moving average approach

### Python Integration
The Rails application communicates with the Python ML service via:
- **stdin/stdout** for data exchange (JSON format)
- **Open3.capture2** for subprocess management
- Virtual environment isolation for Python dependencies

## API Rate Limits

### OpenAI API
- AI insights generation: Limited to once per minute per user (session-based)
- Model: GPT-3.5 Turbo
- Max tokens per request: 300
- Temperature: 0.7

## Known Limitations

1. **Forecasting Accuracy**: Linear regression assumes trends continue - real life is more complex
2. **AI Insights**: Require an OpenAI API key and internet connection
3. **Scenario Simulation**: Based on simplified assumptions about expense reduction
4. **Mobile Responsiveness**: Optimized for desktop browsers
5. **No Data Export**: Currently no feature to export data or forecasts

## Future Enhancements

- Multi-currency support
- Recurring transaction templates
- Budget goal tracking with alerts
- Data export to PDF/Excel
- Mobile-responsive design improvements
- More sophisticated ML models (ARIMA, Prophet)
- Bill reminders and notifications
- Integration with bank APIs (Plaid, Yodlee)

## Troubleshooting

### Database Connection Issues
```bash
# Check PostgreSQL is running
sudo service postgresql status

# Start PostgreSQL if not running
sudo service postgresql start
```

### Python ML Service Errors
```bash
# Ensure virtual environment is activated
cd ml_service
source venv/bin/activate

# Reinstall dependencies
pip install -r requirements.txt
```

### OpenAI API Errors
- Verify API key is correct in `.env`
- Check API key has credits remaining
- Ensure internet connection is active

### Bundle Install Errors
```bash
# If you get permission errors, use local bundle path
bundle config set --local path 'vendor/bundle'
bundle install
```

## Development

### Running Tests
```bash
# Once test suite is implemented
rails test
```

### Code Style
- Follow Ruby Style Guide
- Use Rails best practices
- Keep controllers thin, models fat
- Service objects for business logic

## License

This project is for educational purposes only.

## Disclaimer

**IMPORTANT NOTICE:**

FinTrack is an **educational tool** designed to help you learn about personal finance tracking and forecasting. It is **NOT** a substitute for professional financial advice.

- The forecasts and predictions are based on simple mathematical models and historical data
- AI-generated insights are for educational purposes only
- Always consult with a qualified financial advisor for personalized financial guidance
- The developers assume no liability for financial decisions made based on this application

## Contributing

This is an educational project. Feel free to fork and modify for your own learning purposes.

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review the code and comments for implementation details
3. Consult Rails and Python documentation for framework-specific issues

## Acknowledgments

- Built with Ruby on Rails
- Machine learning powered by scikit-learn
- AI insights powered by OpenAI
- Visualizations created with Chart.js
- Authentication handled by Devise

---

**Remember:** FinTrack is for educational purposes only. Make informed financial decisions with professional guidance.
