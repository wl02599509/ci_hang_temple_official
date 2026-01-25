module Admin
  class UsersController < Admin::ApplicationController
    before_action :authenticate_user!

    def index
      @users = User.all.order(status: :desc)
    end
  end
end
