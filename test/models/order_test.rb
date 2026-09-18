require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "tracking_url for flash carrier" do
    order = orders(:paid_order)
    order.update!(shipping_carrier: :flash, tracking_number: "TH123456")

    assert_equal "https://www.flashexpress.co.th/tracking/?se=TH123456", order.tracking_url
  end

  test "tracking_url is nil without tracking number" do
    order = orders(:paid_order)

    assert_nil order.tracking_url
  end

  test "timeline marks paid step as current when paid" do
    order = orders(:paid_order)
    current = order.timeline_steps.find { |s| s[:current] }

    assert_equal :preparing, current[:key]
  end
end
