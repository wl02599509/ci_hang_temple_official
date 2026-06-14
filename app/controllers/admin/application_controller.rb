module Admin
  class ApplicationController < ActionController::Base
    include Pundit::Authorization

    layout "admin/application"

    include Pagy::Method

    # Pundit raises this when a policy denies an action. Redirect back to the
    # member list with a friendly message instead of surfacing a 500.
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized
      redirect_to admin_users_path, alert: t("pundit.not_authorized")
    end
  end
end
