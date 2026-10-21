require "test_helper"

class ProductVariantTest < ActiveSupport::TestCase
  test "available_quantity returns stock minus reserved for regular variant" do
    variant = product_variants(:one)
    variant.update!(is_preorder: false, stock_quantity: 10, reserved_quantity: 3)
    assert_equal 7, variant.available_quantity
  end

  test "available_quantity returns quota minus preorder_reserved for preorder variant" do
    variant = product_variants(:one)
    variant.update!(is_preorder: true, preorder_quota: 20, preorder_reserved: 5, preorder_release_date: 1.month.from_now)
    assert_equal 15, variant.available_quantity
  end

  test "preorder_available? returns true when preorder open and quota available" do
    variant = product_variants(:one)
    variant.update!(is_preorder: true, preorder_quota: 10, preorder_reserved: 5, preorder_release_date: 1.month.from_now)
    assert variant.preorder_available?
  end

  test "preorder_available? returns false when preorder closed by date" do
    variant = product_variants(:one)
    variant.update!(
      is_preorder: true,
      preorder_quota: 10,
      preorder_reserved: 5,
      preorder_release_date: 1.month.from_now,
      preorder_closes_at: 1.day.ago
    )
    assert_not variant.preorder_available?
  end

  test "preorder_available? returns false when quota is full" do
    variant = product_variants(:one)
    variant.update!(is_preorder: true, preorder_quota: 10, preorder_reserved: 10, preorder_release_date: 1.month.from_now)
    assert_not variant.preorder_available?
  end

  test "validates preorder requires release date" do
    variant = product_variants(:one)
    variant.is_preorder = true
    variant.preorder_release_date = nil
    assert_not variant.valid?
    assert_includes variant.errors[:preorder_release_date], "ต้องระบุวันที่วางจำหน่าย"
  end

  test "validates preorder_reserved does not exceed quota" do
    variant = product_variants(:one)
    variant.update!(is_preorder: true, preorder_quota: 10, preorder_release_date: 1.month.from_now)
    variant.preorder_reserved = 15
    assert_not variant.valid?
    assert_includes variant.errors[:preorder_reserved], "ต้องไม่เกินโควต้าพรีออเดอร์"
  end

  test "validates reserved does not exceed stock for non-preorder" do
    variant = product_variants(:one)
    variant.is_preorder = false
    variant.stock_quantity = 10
    variant.reserved_quantity = 15
    assert_not variant.valid?
    assert_includes variant.errors[:reserved_quantity], "ต้องไม่เกินจำนวนสต็อก"
  end
end
