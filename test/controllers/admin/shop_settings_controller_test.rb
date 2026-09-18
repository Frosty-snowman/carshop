require "test_helper"

module Admin
  class ShopSettingsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
      sign_in_as @admin
      @shop_setting = shop_settings(:default)
    end

    test "upload qr code" do
      file = fixture_file_upload("qr.png", "image/png")

      patch admin_shop_setting_path, params: {
        shop_setting: { qr_code: file }
      }

      assert_redirected_to edit_admin_shop_setting_path
      assert ShopSetting.current.qr_code.attached?, "QR code should be attached"
    end
  end
end
