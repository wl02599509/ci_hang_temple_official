# frozen_string_literal: true

module Admin
  module Users
    class SessionsController < Devise::SessionsController
      layout 'admin'

      before_action :configure_sign_in_params, only: [:create]

      # GET /resource/sign_in
      # def new
      #   super
      # end

      # POST /resource/sign_in
      # def create
      #   super
      # end

      # DELETE /resource/sign_out
      # def destroy
      #   super
      # end

      # protected

      # If you have extra params to permit, append them to the sanitizer.
      def configure_sign_in_params
        devise_parameter_sanitizer.permit(:sign_in, keys: [:id_card_number])
      end

      def after_sign_in_path_for(_resource)
        admin_root_path
      end

      def after_sign_out_path_for(_resource)
        admin_root_path
      end
    end
  end
end
