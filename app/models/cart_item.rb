class CartItem < ApplicationRecord
  belongs_to :user
  belongs_to :product_variant

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validate :quantity_within_stock

  def subtotal
    product_variant.price * quantity
  end

  private

  def quantity_within_stock
    return if product_variant.blank?

    if quantity > product_variant.stock_quantity
      errors.add(:quantity, "เกินจำนวนในสต็อก (เหลือ #{product_variant.stock_quantity} ใบ)")
    end
  end
end
