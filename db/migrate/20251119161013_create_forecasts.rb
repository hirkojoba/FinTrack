class CreateForecasts < ActiveRecord::Migration[8.1]
  def change
    create_table :forecasts do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :forecast_horizon_months, null: false
      t.decimal :starting_balance, precision: 10, scale: 2, null: false
      t.jsonb :predicted_monthly_net_savings, default: []
      t.datetime :generated_at, null: false

      t.timestamps
    end

    add_index :forecasts, :generated_at
  end
end
