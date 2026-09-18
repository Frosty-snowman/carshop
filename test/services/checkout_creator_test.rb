require "test_helper"

class CheckoutCreatorTest < ActiveSupport::TestCase
  setup do
    @customer = users(:customer)
    @variant = product_variants(:blue_eyes_new_en)
    @customer.cart_items.destroy_all
    @customer.cart_items.create!(product_variant: @variant, quantity: 1)
    @variant.update!(stock_quantity: 5, reserved_quantity: 0)
  end

  test "creates order with stock reservation and shipping" do
    order = CheckoutCreator.call(
      user: @customer,
      params: {
        recipient_name: "Test",
        phone: "0812345678",
        address: "123 Road",
        postal_code: "83120",
        payment_method: "bank_transfer"
      }
    )

    assert order.pending_payment?
    assert_equal 300, order.subtotal_amount.to_f
    assert_equal 50, order.shipping_fee.to_f
    assert_equal 350, order.total_amount.to_f
    assert_equal "standard", order.shipping_zone
    assert order.payment_deadline_at.present?
    assert_equal 1, @variant.reload.reserved_quantity
    assert_equal 0, @customer.cart_items.count
  end

  test "raises when stock not available" do
    @variant.update!(stock_quantity: 1, reserved_quantity: 1)

    assert_raises(CheckoutCreator::Error) do
      CheckoutCreator.call(
        user: @customer,
        params: {
          recipient_name: "Test",
          phone: "0812345678",
          address: "123 Road",
          postal_code: "10110",
          payment_method: "bank_transfer"
        }
      )
    end
  end
end
