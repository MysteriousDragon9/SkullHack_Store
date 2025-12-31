# spec/support/devise.rb
require "devise"

RSpec.configure do |config|
  # Controller specs
  config.include Devise::Test::ControllerHelpers, type: :controller

  # Request specs
  config.include Devise::Test::IntegrationHelpers, type: :request

  # System specs (Capybara)
  config.include Devise::Test::IntegrationHelpers, type: :system

  # Optional: Warden helpers for feature/system specs
  # config.include Warden::Test::Helpers
  # config.after(:each) { Warden.test_reset! }
end
