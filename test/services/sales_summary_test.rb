require "test_helper"

class SalesSummaryTest < ActiveSupport::TestCase
  setup do
    @summary = SalesSummary.new
  end

  test "counts revenue orders for shipped status" do
    order = orders(:shipped_order)

    assert_includes SalesSummary::REVENUE_STATUSES.map(&:to_s), order.status
    assert @summary.order_count(period: :all) >= 1
  end

  test "daily_revenue returns 7 days" do
    assert_equal 7, @summary.daily_revenue.length
  end

  test "daily_revenue labels use Thai day abbreviations" do
    I18n.with_locale(:th) do
      labels = @summary.daily_revenue.map { |day| day[:label] }

      assert labels.all? { |label| !label.include?("Translation missing") }
      assert labels.all? { |label| label.match?(/\A\S+ \d{2}\/\d{2}\z/) }
    end
  end

  test "pending_slip_count includes submitted orders" do
    assert @summary.pending_slip_count >= 1
  end
end
