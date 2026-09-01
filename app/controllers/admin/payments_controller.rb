module Admin
  class PaymentsController < BaseController
    before_action :set_payment

    def approve
      PaymentApprover.call(payment: @payment, admin_note: params[:admin_note])
      redirect_to admin_order_path(@payment.order), notice: "อนุมัติการชำระเงินแล้ว"
    rescue PaymentApprover::Error => e
      redirect_to admin_order_path(@payment.order), alert: e.message
    end

    def reject
      unless @payment.pending? && @payment.order.payment_submitted?
        redirect_to admin_order_path(@payment.order), alert: "ปฏิเสธไม่ได้ในสถานะนี้"
        return
      end

      @payment.update!(status: :rejected, admin_note: params[:admin_note])
      @payment.order.update!(status: :payment_rejected)
      redirect_to admin_order_path(@payment.order), notice: "ปฏิเสธสลิปแล้ว ลูกค้าสามารถแนบใหม่ได้"
    end

    private

    def set_payment
      @payment = Payment.includes(order: { order_items: :product_variant }).find(params[:id])
    end
  end
end
