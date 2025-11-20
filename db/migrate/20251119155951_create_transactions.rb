class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.string :description, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :category

      t.timestamps
    end

    add_index :transactions, :date
    add_index :transactions, :category
  end
end
