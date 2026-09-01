module Admin
  class ShopSettingsController < BaseController
    def edit
      @shop_setting = ShopSetting.current
    end

    def update
      @shop_setting = ShopSetting.current
      if @shop_setting.update(shop_setting_params)
        redirect_to edit_admin_shop_setting_path, notice: "บันทึกข้อมูลชำระเงินแล้ว"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def shop_setting_params
      params.require(:shop_setting).permit(:bank_name, :account_number, :account_name, :payment_instructions, :qr_code)
    end
  end
end
