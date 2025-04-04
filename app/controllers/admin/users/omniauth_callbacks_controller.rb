# frozen_string_literal: true

module Admin
  module Users
    class OmniauthCallbacksController < Devise::OmniauthCallbacksController
      layout 'admin'

      # You should also create an action method in this controller like this:
      # def twitter
      # end

      # More info at:
      # https://github.com/heartcombo/devise#omniauth

      # GET|POST /resource/auth/twitter
      # def passthru
      #   super
      # end

      # GET|POST /users/auth/twitter/callback
      # def failure
      #   super
      # end

      # protected

      # The path used when OmniAuth fails
      # def after_omniauth_failure_path_for(scope)
      #   super(scope)
      # end
    end
  end
end
