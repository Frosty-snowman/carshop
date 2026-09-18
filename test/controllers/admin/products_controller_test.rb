require "test_helper"

module Admin
  class ProductsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      sign_in_as @admin
    end

    test "index filters products by category" do
      get admin_products_path, params: { category_id: categories(:pokemon).id }

      assert_response :success
      assert_match "Pikachu VMAX", response.body
      assert_no_match "Blue-Eyes White Dragon", response.body
    end

    test "index shows all products without filter" do
      get admin_products_path

      assert_response :success
      assert_match "Pikachu VMAX", response.body
      assert_match "Blue-Eyes White Dragon", response.body
    end

    test "destroy deletes product without order history" do
      product = Product.create!(name: "Test Card", category: categories(:pokemon))

      assert_difference("Product.count", -1) do
        delete admin_product_path(product)
      end

      assert_redirected_to admin_products_path
      assert_equal "ลบการ์ดแล้ว", flash[:notice]
    end

    test "destroy blocks product with order history" do
      product = products(:pikachu)

      assert_no_difference("Product.count") do
        delete admin_product_path(product)
      end

      assert_redirected_to admin_product_path(product)
      assert_equal "ลบไม่ได้ เพราะมีประวัติออเดอร์ที่เกี่ยวข้อง", flash[:alert]
    end
  end
end
