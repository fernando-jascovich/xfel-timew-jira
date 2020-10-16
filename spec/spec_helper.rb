# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

SimpleCov.start do
  coverage_dir '/tmp/coverage'
  add_filter '/spec/'
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
