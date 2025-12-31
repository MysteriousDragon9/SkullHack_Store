# spec/rails_helper.rb
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

# Load support files
Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

# Maintain test schema
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_path = Rails.root.join("spec/fixtures")
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # Randomize test order
  config.order = :random
  Kernel.srand config.seed
end

# --- DatabaseCleaner setup ---
require "database_cleaner/active_record"

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.strategy = example.metadata[:no_transaction] ? :truncation : :transaction
    DatabaseCleaner.cleaning { example.run }
  end

  # FactoryBot shorthand
  config.include FactoryBot::Syntax::Methods

  # Devise helpers
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system
end

# --- Shoulda Matchers ---
Shoulda::Matchers.configure do |with|
  with.integrate do |config|
    config.test_framework :rspec
    config.library :rails
  end
end
