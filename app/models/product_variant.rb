class ProductVariant < ApplicationRecord
  belongs_to :product
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error

  enum :condition, { new_condition: 0, used: 1 }, prefix: :condition
  enum :language, { th: 0, en: 1, ja: 2 }

  validates :price, numericality: { greater_than: 0 }
  validates :stock_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :condition, uniqueness: { scope: %i[product_id language] }

  def in_stock?
    stock_quantity.positive?
  end

  def display_label
    "#{condition_label} / #{language_label}"
  end

  def condition_label
    condition_new_condition? ? "สภาพใหม่" : "สภาพใช้งานแล้ว"
  end

  def language_label
    { "th" => "ไทย", "en" => "English", "ja" => "日本語" }[language]
  end

  def subtotal_for(quantity)
    price * quantity
  end
end
