#!/usr/bin/env python3
"""
FinTrack ML Forecasting Service
Simple ML-based forecasting for monthly net savings
"""

import sys
import json
import numpy as np
from sklearn.linear_model import LinearRegression
import warnings
warnings.filterwarnings('ignore')

def forecast_savings(net_savings_history, forecast_horizon):
    """
    Forecast future net savings based on historical data.

    Args:
        net_savings_history: List of historical monthly net savings
        forecast_horizon: Number of months to forecast

    Returns:
        List of predicted net savings for future months
    """
    if not net_savings_history or len(net_savings_history) < 2:
        # Not enough data, return simple average
        avg = np.mean(net_savings_history) if net_savings_history else 0
        return [float(avg)] * forecast_horizon

    # Prepare data for linear regression
    X = np.array(range(len(net_savings_history))).reshape(-1, 1)
    y = np.array(net_savings_history)

    # Train linear regression model
    model = LinearRegression()
    model.fit(X, y)

    # Generate predictions for future months
    future_months = np.array(range(len(net_savings_history),
                                   len(net_savings_history) + forecast_horizon)).reshape(-1, 1)
    predictions = model.predict(future_months)

    # Convert to list of floats
    return [float(pred) for pred in predictions]

def moving_average_forecast(net_savings_history, forecast_horizon, window=3):
    """
    Simple moving average forecast as a fallback method.

    Args:
        net_savings_history: List of historical monthly net savings
        forecast_horizon: Number of months to forecast
        window: Moving average window size

    Returns:
        List of predicted net savings for future months
    """
    if not net_savings_history:
        return [0.0] * forecast_horizon

    if len(net_savings_history) < window:
        # Use simple average if not enough data
        avg = np.mean(net_savings_history)
        return [float(avg)] * forecast_horizon

    # Calculate moving average of last 'window' months
    recent_avg = np.mean(net_savings_history[-window:])

    # Return the same average for all future months (conservative estimate)
    return [float(recent_avg)] * forecast_horizon

def main():
    """
    Main entry point for the forecasting service.
    Reads JSON from stdin, returns JSON to stdout.
    """
    try:
        # Read input from stdin
        input_data = json.load(sys.stdin)

        # Extract parameters
        net_savings = input_data.get('net_savings', [])
        forecast_horizon = input_data.get('forecast_horizon', 12)
        method = input_data.get('method', 'linear')  # 'linear' or 'moving_average'

        # Validate inputs
        if forecast_horizon <= 0 or forecast_horizon > 24:
            raise ValueError("Forecast horizon must be between 1 and 24 months")

        # Generate forecast
        if method == 'moving_average':
            predictions = moving_average_forecast(net_savings, forecast_horizon)
        else:
            predictions = forecast_savings(net_savings, forecast_horizon)

        # Prepare output
        output = {
            'success': True,
            'predicted_net_savings': predictions,
            'method_used': method,
            'data_points': len(net_savings)
        }

        # Write output to stdout
        print(json.dumps(output))
        sys.exit(0)

    except json.JSONDecodeError as e:
        error_output = {
            'success': False,
            'error': f'Invalid JSON input: {str(e)}'
        }
        print(json.dumps(error_output))
        sys.exit(1)

    except Exception as e:
        error_output = {
            'success': False,
            'error': f'Forecasting error: {str(e)}'
        }
        print(json.dumps(error_output))
        sys.exit(1)

if __name__ == '__main__':
    main()
