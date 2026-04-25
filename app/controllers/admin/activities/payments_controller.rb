module Admin
  module Activities
    class PaymentsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_activity

      def pay
        registration_ids = Array(params[:registration_ids]).map(&:to_i)
        payment_method = params[:payment_method]
        collector = params[:collector]

        registrations = @activity.activity_registrations
          .pending
          .where(id: registration_ids)

        registrations.each do |reg|
          reg.update!(
            status: :paid,
            payment_method: payment_method,
            collector: collector,
            paid_at: Time.current
          )
        end

        @registrations = @activity.activity_registrations.includes(:user)
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_activity_registrations_path(@activity) }
        end
      end

      private

      def set_activity
        @activity = Activity.find(params[:activity_id])
      end
    end
  end
end
