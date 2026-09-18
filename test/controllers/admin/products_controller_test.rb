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
  end
end
