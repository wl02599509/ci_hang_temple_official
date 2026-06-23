module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :set_user, only: [ :show, :edit, :update, :destroy ]

    helper_method :display_order_columns

    def index
      @q = User.ransack(params[:q])
      @pagy, @users = pagy(:offset, @q.result.order(status: :asc))
    end

    def export
      @q = User.ransack(params[:q])
      @users = @q.result.order(status: :asc)

      respond_to do |format|
        format.xlsx do
          render xlsx: "export", filename: I18n.t("export.filename.users")
        end
      end
    end

    def show
    end

    def new
      authorize User
      @user = User.new
    end

    def create
      authorize User
      @user = User.new(user_params)

      if @user.save
        redirect_to admin_users_path, notice: t("admin.users.create.success", member: member_label(@user))
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @user
    end

    def update
      authorize @user

      if @user.update(user_params)
        redirect_to admin_users_path, notice: t("admin.users.update.success", member: member_label(@user))
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @user

      if @user == current_user
        redirect_to admin_users_path, alert: t("admin.users.destroy.self_forbidden")
      else
        label = member_label(@user)
        @user.destroy
        redirect_to admin_users_path, notice: t("admin.users.destroy.success", member: label)
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    # 身份姓名(身分證字號)，例：善信大德王小明(A12345678)
    def member_label(user)
      "#{helpers.display_status(user)}#{user.name}(#{user.id_number})"
    end

    def user_params
      params.require(:user).permit(
        :id_number, :name, :phone_number, :birth_date, :address, :email, :zodiac, :status
      )
    end

    def display_order_columns
      %i[ status name id_number sex birth_date zodiac address ]
    end
  end
end
