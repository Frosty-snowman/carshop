class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product_variant

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than: 0 }

  def subtotal
    unit_price * quantity
  end

  def product_name
    product_variant.product.name
  end
end
