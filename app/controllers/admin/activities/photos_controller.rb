module Admin
  module Activities
    class PhotosController < ApplicationController
      before_action :authenticate_user!
      before_action :set_activity

      def destroy
        @activity.photos.find(params[:id]).purge
        redirect_to edit_admin_activity_path(@activity), notice: "照片已刪除"
      end

      private

      def set_activity
        @activity = Activity.find(params[:activity_id])
      end
    end
  end
end
