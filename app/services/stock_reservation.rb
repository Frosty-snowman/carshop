class StockReservation
  class Error < StandardError; end

  def self.reserve!(order_items)
    order_items.each do |item|
      variant = item.product_variant
      variant.with_lock do
        if variant.available_quantity < item.quantity
          raise Error, "#{variant.product.name} (#{variant.display_label}) มีสต็อกไม่พอ"
        end

        variant.increment!(:reserved_quantity, item.quantity)
      end
    end
  end

  def self.release!(order_items)
    order_items.each do |item|
      variant = item.product_variant
      variant.with_lock do
        release_amount = [ item.quantity, variant.reserved_quantity ].min
        variant.decrement!(:reserved_quantity, release_amount) if release_amount.positive?
      end
    end
  end

  def self.fulfill!(order_items)
    order_items.each do |item|
      variant = item.product_variant
      variant.with_lock do
        if variant.reserved_quantity < item.quantity
          raise Error, "#{variant.product.name} การจองสต็อกไม่ตรงกับออเดอร์"
        end
        if variant.stock_quantity < item.quantity
          raise Error, "#{variant.product.name} สต็อกไม่พอ"
        end

        variant.decrement!(:stock_quantity, item.quantity)
        variant.decrement!(:reserved_quantity, item.quantity)
      end
    end
  end
end
