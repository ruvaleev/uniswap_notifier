# frozen_string_literal: true

require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.configure do |config|
  config.after(testing: :inline) { Sidekiq::Testing.fake! }
  config.before(testing: :inline) { Sidekiq::Testing.inline! }
end
