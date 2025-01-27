# frozen_string_literal: true

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

abort('The Rails is running in production mode!') if Rails.env.production?

require 'rspec/rails'

require 'shoulda/matchers'
require 'faker'
require 'factory_bot'
require 'sidekiq/testing'

Rails.root.glob('spec/support/**/*.rb').sort.each { |f| require f }

RSpec.configure do |config|

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
