module Admin
  class FeatureRequestsController < BaseController
    before_action :set_feature_request, only: %i[update]

    def index
      @feature_requests = FeatureRequest.recent.includes(:user)
      @feature_requests = @feature_requests.where(status: params[:status]) if params[:status].present?
    end

    def update
      if @feature_request.update(status: params[:status])
        redirect_to admin_feature_requests_path, notice: "อัปเดตสถานะคำร้องแล้ว"
      else
        redirect_to admin_feature_requests_path, alert: @feature_request.errors.full_messages.to_sentence
      end
    end

    private

    def set_feature_request
      @feature_request = FeatureRequest.find(params[:id])
    end
  end
end
