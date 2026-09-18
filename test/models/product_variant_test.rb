require "test_helper"

class ProductVariantTest < ActiveSupport::TestCase
  test "replenish! adds to stock_quantity" do
    variant = product_variants(:pikachu_new_th)

    variant.replenish!(5)

    assert_equal 15, variant.reload.stock_quantity
  end

  test "replenish! rejects zero or negative amounts" do
    variant = product_variants(:pikachu_new_th)

    assert_raises(ArgumentError) { variant.replenish!(0) }
    assert_raises(ArgumentError) { variant.replenish!(-3) }
  end
end
