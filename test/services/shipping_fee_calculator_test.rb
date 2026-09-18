require "test_helper"

class ShippingFeeCalculatorTest < ActiveSupport::TestCase
  test "always 50 baht regardless of postal code" do
    [ "10110", "10220", "83120", "95000" ].each do |code|
      result = ShippingFeeCalculator.call(postal_code: code)

      assert_equal "standard", result[:zone]
      assert_equal 50, result[:shipping_fee]
    end
  end

  test "rejects invalid postal code" do
    assert_raises(ShippingFeeCalculator::Error) do
      ShippingFeeCalculator.call(postal_code: "123")
    end
  end
end
