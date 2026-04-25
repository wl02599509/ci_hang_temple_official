module Admin
  module Activities
    class RegistrationsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_activity

      def index
        @registrations = @activity.activity_registrations.includes(:user)
      end

      def new_modal
      end

      def cancel_modal
        @registration_ids = Array(params[:registration_ids]).map(&:to_i)
        registrations = @activity.activity_registrations.where(id: @registration_ids)
        @has_paid = registrations.any?(&:paid?)
        @has_mixed = @has_paid && registrations.any?(&:pending?)
      end

      def pay_modal
        @registration_ids = Array(params[:registration_ids]).map(&:to_i)
      end

      def user_search
        query = params[:q].to_s.strip
        @users = if query.present?
          User.where("name LIKE ? OR id_number LIKE ?", "%#{query}%", "%#{query}%")
        else
          User.none
        end
        @query = query
      end

      def create
        user_ids = Array(params[:user_ids]).map(&:to_i).select(&:positive?)
        already_active = @activity.activity_registrations.active.pluck(:user_id)
        new_user_ids = user_ids - already_active

        new_user_ids.each do |uid|
          @activity.activity_registrations.create!(user_id: uid, status: :pending)
        end

        @registrations = @activity.activity_registrations.includes(:user)
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to admin_activity_registrations_path(@activity) }
        end
      end

      def cancel
        registration_ids = Array(params[:registration_ids]).map(&:to_i)
        cancel_reason = params[:cancel_reason]
        refund_amount = params[:refund_amount].presence

        registrations = @activity.activity_registrations
          .cancellable
          .where(id: registration_ids)

        registrations.each do |reg|
          attrs = {
            status: :cancelled,
            cancel_reason: cancel_reason,
            cancelled_at: Time.current
          }

          if reg.paid? && refund_amount.present?
            attrs[:refund_amount] = refund_amount
            attrs[:refunded_at] = Time.current
          end

          reg.update!(attrs)
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
