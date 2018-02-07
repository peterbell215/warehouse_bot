require 'benchmark'
require 'active_record'
require 'active_model'
require 'factory_bot'
require 'faker'
require 'database_cleaner'

require 'bundler/setup'

require 'warehouse_bot'
require 'support/models'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
load File.expand_path('spec/support/schema.rb')

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Factory Bot configuration
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
