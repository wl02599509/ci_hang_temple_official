# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin User Signin Authentication', type: :feature do
  describe 'Sign in with status verification' do
    User::STATUSES.each_key do |key|
      context "with #{key} status" do
        it_behaves_like 'admin signin attempt', key, key != :general
      end
    end
  end
end
