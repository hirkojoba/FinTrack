class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :transactions, dependent: :destroy
  has_many :forecasts, dependent: :destroy
  has_many :scenarios, dependent: :destroy

  validates :monthly_income, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :savings_goal_amount, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :savings_goal_months, numericality: { only_integer: true, greater_than: 0, allow_nil: true }
end
