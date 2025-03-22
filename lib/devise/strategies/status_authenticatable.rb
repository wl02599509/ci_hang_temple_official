# frozen_string_literal: true

require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class StatusAuthenticatable < Authenticatable
      def authenticate!
        resource = valid_password? && mapping.to.find_for_database_authentication(authentication_hash)
        return fail!(:invalid) if resource.blank?
        return fail!(:unauthorized_status) if resource.general_status?

        success!(resource)
      end
    end
  end
end

Warden::Strategies.add(:status_authenticatable, Devise::Strategies::StatusAuthenticatable)
