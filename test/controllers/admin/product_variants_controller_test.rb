require "test_helper"

module Admin
  class ProductVariantsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      @product = products(:pikachu)
      @variant = product_variants(:pikachu_new_th)
      sign_in_as @admin
    end

    test "replenish adds stock to variant" do
      post replenish_admin_product_product_variant_path(@product, @variant),
           params: { amount: 7 }

      assert_redirected_to admin_product_path(@product)
      assert_equal 17, @variant.reload.stock_quantity
    end

    test "replenish rejects invalid amount" do
      post replenish_admin_product_product_variant_path(@product, @variant),
           params: { amount: 0 }

      assert_redirected_to admin_product_path(@product)
      assert_equal 10, @variant.reload.stock_quantity
    end
  end
end
