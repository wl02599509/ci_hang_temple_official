module Admin
  class ActivitiesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_activity, only: [ :show, :edit, :update, :destroy ]

    def index
      @q = Activity.ransack(params[:q])
      activities = @q.result(distinct: true)

      if params[:roc_year].present?
        gregorian_year = params[:roc_year].to_i + 1911
        activities = activities.where("EXTRACT(YEAR FROM event_date) = ?", gregorian_year)
      end

      @activities = activities.order(event_date: :desc)
    end

    def show
    end

    def new
      @activity = Activity.new
    end

    def create
      @activity = Activity.new(activity_params)
      if @activity.save
        redirect_to admin_activities_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @activity.update(activity_params)
        redirect_to admin_activities_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @activity.destroy
      redirect_to admin_activities_path
    end

    private

    def set_activity
      @activity = Activity.find(params[:id])
    end

    def activity_params
      params.require(:activity).permit(
        :title, :description, :notes, :event_date,
        :registration_start_date, :registration_end_date,
        :fee, :status, photos: []
      )
    end
  end
end
