class Scenario < ApplicationRecord
  belongs_to :user
  belongs_to :forecast

  validates :extra_monthly_savings, numericality: { greater_than_or_equal_to: 0 }
  validates :expense_reduction_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  scope :recent, -> { order(created_at: :desc) }
end
