require "test_helper"

module Admin
  class PaymentsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      sign_in_as @admin
    end

    test "approve payment from payment_submitted order" do
      order = orders(:submitted_order)
      payment = payments(:submitted_payment)

      post approve_admin_payment_path(payment)

      assert_redirected_to admin_order_path(order)
      assert order.reload.paid?
      assert payment.reload.approved?
    end
  end
end
