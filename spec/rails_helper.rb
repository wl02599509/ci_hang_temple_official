# frozen_string_literal: true

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

abort('The Rails is running in production mode!') if Rails.env.production?

require 'rspec/rails'

require 'shoulda/matchers'
require 'faker'
require 'factory_bot'

Rails.root.glob('spec/support/**/*.rb').sort.each { |f| require f }

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
