require "test_helper"

class ProductVariantTest < ActiveSupport::TestCase
  test "replenish! adds to stock_quantity" do
    variant = product_variants(:pikachu_new_th)

    variant.replenish!(5)

    assert_equal 15, variant.reload.stock_quantity
  end

  test "language_label uses Thai En Jp labels" do
    assert_equal "ภาษาไทย", product_variants(:pikachu_new_th).language_label
    assert_equal "En", product_variants(:blue_eyes_new_en).language_label
  end

  test "replenish! rejects zero or negative amounts" do
    variant = product_variants(:pikachu_new_th)

    assert_raises(ArgumentError) { variant.replenish!(0) }
    assert_raises(ArgumentError) { variant.replenish!(-3) }
  end
end
