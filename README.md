# FinTrack

A personal finance tracker with ML-powered forecasting. Track your spending, visualize trends, and get predictions on your future savings.

## What it does

- Track income and expenses with automatic categorization
- Import transactions from CSV files
- Visualize spending patterns with interactive charts
- Get 12-month savings forecasts using machine learning
- Run "what-if" scenarios to see how lifestyle changes affect your savings
- AI-generated insights about your financial trends (requires OpenAI API key)

## Tech Stack

**Backend:** Ruby on Rails 8.1, PostgreSQL
**Frontend:** Vanilla JS, Chart.js
**ML:** Python with scikit-learn for forecasting
**Auth:** Devise

## Setup

### Prerequisites
- Ruby 3.2+
- PostgreSQL
- Python 3.12+
- OpenAI API key (optional, for AI insights)

### Installation

1. Clone and install dependencies:
```bash
git clone <your-repo-url>
cd FinTrack
bundle install
```

2. Set up Python for ML forecasting:
```bash
cd ml_service
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cd ..
```

3. Database setup:
```bash
rails db:create db:migrate
```

4. Add your OpenAI key (optional):
Create a `.env` file:
```
OPENAI_API_KEY=your_key_here
```

5. Start the server:
```bash
rails server
```

Visit `http://localhost:3000`

## Usage

1. Sign up and create an account
2. Add transactions manually or upload a CSV file
3. Click "Run Forecast" to generate ML predictions
4. Use the sliders to simulate different scenarios

### CSV Format
```csv
date,description,amount,category
2024-01-15,Salary,3000.00,Income
2024-01-16,Groceries,-125.50,Groceries
```
(Expenses are negative, income is positive)

## How it works

The app uses linear regression to analyze your historical spending and predict future net savings. It's a simple educational project - don't use it for actual financial planning.

## Deployment

Deployed on Railway. The Dockerfile handles both Ruby and Python dependencies.

## License

MIT - Educational purposes only. Not financial advice.
