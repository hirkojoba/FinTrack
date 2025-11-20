class CreateScenarios < ActiveRecord::Migration[8.1]
  def change
    create_table :scenarios do |t|
      t.references :user, null: false, foreign_key: true
      t.references :forecast, null: false, foreign_key: true
      t.string :name
      t.decimal :extra_monthly_savings, precision: 10, scale: 2, default: 0
      t.decimal :expense_reduction_percent, precision: 5, scale: 2, default: 0
      t.jsonb :resulting_predicted_net_savings, default: []

      t.timestamps
    end

    add_index :scenarios, :created_at
  end
end
