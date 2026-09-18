require "test_helper"

module Admin
  class StockControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      sign_in_as @admin
    end

    test "index shows variants filtered by category" do
      get admin_stock_path, params: { category_id: categories(:pokemon).id }

      assert_response :success
      assert_match "Pikachu VMAX", response.body
      assert_no_match "Blue-Eyes White Dragon", response.body
    end

    test "update replenishes multiple variants" do
      pikachu_variant = product_variants(:pikachu_new_th)
      blue_eyes_variant = product_variants(:blue_eyes_new_en)

      patch admin_stock_path, params: {
        category_id: categories(:pokemon).id,
        replenishments: {
          pikachu_variant.id => 5
        }
      }

      assert_redirected_to admin_stock_path(category_id: categories(:pokemon).id)
      assert_equal 15, pikachu_variant.reload.stock_quantity
      assert_equal 3, blue_eyes_variant.reload.stock_quantity
    end
  end
end
