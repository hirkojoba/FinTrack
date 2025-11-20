class Forecast < ApplicationRecord
  belongs_to :user
  has_many :scenarios, dependent: :destroy

  validates :forecast_horizon_months, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :starting_balance, presence: true
  validates :generated_at, presence: true

  scope :recent, -> { order(generated_at: :desc) }
end
