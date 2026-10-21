class StockReservation
  class Error < StandardError; end

  def self.reserve!(order_items)
    order_items.each do |item|
      variant = item.product_variant
      variant.with_lock do
        if variant.available_quantity < item.quantity
          raise Error, "#{variant.product.name} (#{variant.display_label}) มีสต็อกไม่พอ"
        end

        if variant.is_preorder?
          variant.increment!(:preorder_reserved, item.quantity)
        else
          variant.increment!(:reserved_quantity, item.quantity)
        end
      end
    end
  end

  def self.release!(order_items)
    order_items.each do |item|
      variant = item.product_variant
      variant.with_lock do
        if variant.is_preorder?
          release_amount = [ item.quantity, variant.preorder_reserved ].min
          variant.decrement!(:preorder_reserved, release_amount) if release_amount.positive?
        else
          release_amount = [ item.quantity, variant.reserved_quantity ].min
          variant.decrement!(:reserved_quantity, release_amount) if release_amount.positive?
        end
      end
    end
  end

  def self.fulfill!(order_items)
    order_items.each do |item|
      variant = item.product_variant
      variant.with_lock do
        if variant.is_preorder?
          if variant.preorder_reserved < item.quantity
            raise Error, "#{variant.product.name} การจองพรีออเดอร์ไม่ตรงกับออเดอร์"
          end
          variant.decrement!(:preorder_reserved, item.quantity)
        else
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
end
