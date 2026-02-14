module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!

    helper_method :display_order_columns

    def index
      @q = User.ransack(params[:q])
      @pagy, @users = pagy(:offset, @q.result.order(status: :asc))
    end

    private

    def display_order_columns
      %i[ status name id_number sex birth_date zodiac
          address email
        ]
    end
  end
end
