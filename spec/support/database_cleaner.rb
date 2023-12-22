# frozen_string_literal: true

DEFAULT_STRATEGY = :transaction

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = DEFAULT_STRATEGY

    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each, :multithreaded) do |example|
    DatabaseCleaner.strategy = :truncation
    example.run
    DatabaseCleaner.strategy = DEFAULT_STRATEGY
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
