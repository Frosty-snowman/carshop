require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "index filters in-stock products" do
    sold_out = Product.create!(name: "Sold Out Card", category: categories(:pokemon))
    sold_out.product_variants.create!(
      condition: :new_condition,
      language: :th,
      price: 100,
      stock_quantity: 0,
      reserved_quantity: 0
    )

    get products_path, params: { stock: "in_stock" }

    assert_response :success
    assert_match "Pikachu VMAX", response.body
    assert_no_match "Sold Out Card", response.body
  end

  test "index filters out-of-stock products" do
    sold_out = Product.create!(name: "Sold Out Card", category: categories(:pokemon))
    sold_out.product_variants.create!(
      condition: :new_condition,
      language: :th,
      price: 100,
      stock_quantity: 0,
      reserved_quantity: 0
    )

    get products_path, params: { stock: "out_of_stock" }

    assert_response :success
    assert_match "Sold Out Card", response.body
    assert_no_match "Pikachu VMAX", response.body
  end

  test "index sorts by lowest price first" do
    get products_path, params: { sort: "price_asc" }

    assert_response :success
    assert response.body.index("Blue-Eyes White Dragon") < response.body.index("Pikachu VMAX")
  end

  test "index shows sold-out badge on card" do
    sold_out = Product.create!(name: "Sold Out Card", category: categories(:pokemon))
    sold_out.product_variants.create!(
      condition: :new_condition,
      language: :th,
      price: 100,
      stock_quantity: 0,
      reserved_quantity: 0
    )

    get products_path

    assert_match "product-card--sold-out", response.body
    assert_match "หมดสต็อก", response.body
  end

  test "index shows low-stock badge" do
    get products_path

    assert_response :success
    assert_match "เหลือ 1 ใบ", response.body
  end
end
