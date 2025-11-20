class Transaction < ApplicationRecord
  belongs_to :user

  validates :date, presence: true
  validates :description, presence: true
  validates :amount, presence: true, numericality: true

  scope :income, -> { where("amount > 0") }
  scope :expenses, -> { where("amount < 0") }
  scope :for_month, ->(year, month) {
    where("EXTRACT(YEAR FROM date) = ? AND EXTRACT(MONTH FROM date) = ?", year, month)
  }
  scope :recent, -> { order(date: :desc) }

  def income?
    amount > 0
  end

  def expense?
    amount < 0
  end
end
