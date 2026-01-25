module Admin
  class ApplicationController < ActionController::Base
    layout "admin/application"

    include Pagy::Method
  end
end
