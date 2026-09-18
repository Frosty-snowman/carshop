require "test_helper"

class OrderExpirerTest < ActiveSupport::TestCase
  test "expires pending order and releases stock" do
    order = orders(:expired_order)
    variant = product_variants(:blue_eyes_new_en)
    reserved_before = variant.reserved_quantity

    assert OrderExpirer.expire!(order)

    assert order.reload.cancelled?
    assert_equal reserved_before - 1, variant.reload.reserved_quantity
  end

  test "does not expire order still within deadline" do
    order = orders(:pending_order)

    assert_not OrderExpirer.expire!(order)
    assert order.reload.pending_payment?
  end
end
