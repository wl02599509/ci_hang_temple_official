module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!

    helper_method :display_order_columns

    def index
      @pagy, @users = pagy(:offset, User.all.order(status: :asc))
    end

    private

    def display_order_columns
      %i[ status name id_number sex birth_date zodiac
          address email
        ]
    end
  end
end
