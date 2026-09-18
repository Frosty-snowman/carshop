require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "in_stock? is true when a variant has available quantity" do
    assert products(:pikachu).in_stock?
  end

  test "in_stock? is false when all variants are unavailable" do
    product = products(:pikachu)
    product.product_variants.update_all(stock_quantity: 1, reserved_quantity: 1)

    assert_not product.in_stock?
  end

  test "total_available_stock sums available quantity across variants" do
    assert_equal 9, products(:pikachu).total_available_stock
  end

  test "low_stock? when available stock is at threshold" do
    assert products(:blue_eyes).low_stock?
  end

  test "low_stock? is false when sold out" do
    product = products(:blue_eyes)
    product.product_variants.update_all(stock_quantity: 0, reserved_quantity: 0)

    assert_not product.low_stock?
  end

  test "out_of_stock scope excludes in-stock products" do
    sold_out = Product.create!(name: "Sold Out Card", category: categories(:pokemon))
    sold_out.product_variants.create!(
      condition: :new_condition,
      language: :th,
      price: 100,
      stock_quantity: 0,
      reserved_quantity: 0
    )

    assert_includes Product.out_of_stock, sold_out
    assert_not_includes Product.out_of_stock, products(:pikachu)
  end
end
