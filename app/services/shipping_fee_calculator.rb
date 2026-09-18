class ShippingFeeCalculator
  FEE = 50

  class Error < StandardError; end

  def self.call(postal_code:)
    new(postal_code:).call
  end

  def self.zone_label(_zone_key = "standard")
    "ปกติ"
  end

  def initialize(postal_code:)
    @postal_code = postal_code.to_s.gsub(/\D/, "")
  end

  def call
    raise Error, "กรุณากรอกรหัสไปรษณีย์ 5 หลัก" unless postal_code.match?(/\A\d{5}\z/)

    {
      postal_code: postal_code,
      zone: "standard",
      zone_label: "ปกติ",
      shipping_fee: FEE
    }
  end

  private

  attr_reader :postal_code
end
