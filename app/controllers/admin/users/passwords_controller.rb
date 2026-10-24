# frozen_string_literal: true

module Admin
  module Users
    class PasswordsController < Devise::PasswordsController
      layout "admin/application"
      # GET /resource/password/new
      # def new
      #   super
      # end

      # POST /resource/password
      # def create
      #   super
      # end

      # GET /resource/password/edit?reset_password_token=abcdef
      # def edit
      #   super
      # end

      # PUT /resource/password
      # def update
      #   super
      # end

      protected

      # Redirect to admin dashboard after resetting password
      def after_resetting_password_path_for(resource)
        Devise.sign_in_after_reset_password ? admin_root_path : new_session_path(resource_name)
      end

      # The path used after sending reset password instructions
      # def after_sending_reset_password_instructions_path_for(resource_name)
      #   super(resource_name)
      # end
    end
  end
end
