class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { customer: 0, admin: 1 }, default: :customer

  has_many :cart_items, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :name, presence: true

  def admin?
    role == "admin"
  end
end
