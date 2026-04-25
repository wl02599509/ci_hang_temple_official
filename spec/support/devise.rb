RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request

  config.include Warden::Test::Helpers, type: :feature
  config.after(:each, type: :feature) { Warden.test_reset! }
end
