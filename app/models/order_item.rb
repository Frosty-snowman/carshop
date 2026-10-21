class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product_variant

  enum :preorder_status, {
    fulfilled: 0,
    pending_fulfillment: 1,
    refund_needed: 2
  }, prefix: :preorder

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than: 0 }

  def subtotal
    unit_price * quantity
  end

  def product_name
    product_variant.product.name
  end

  def preorder_status_label
    return nil unless is_preorder?

    {
      "fulfilled" => "ได้รับสินค้าแล้ว",
      "pending_fulfillment" => "รอรับสินค้า",
      "refund_needed" => "ต้องคืนเงิน"
    }[preorder_status]
  end
end
