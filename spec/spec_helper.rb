ENV['RAILS_ENV'] = 'test'
ENV['DATABASE_URL'] = 'sqlite3://localhost/tmp/composition_test'

require 'bundler/setup'
require 'rails'
case Rails.version
  when '3.2.22.5'
    require 'support/apps/rails3_2'
  when '4.2.7.1'
    require 'support/apps/rails4_2'
  when '5.0.2'
    require 'support/apps/rails5_0'
end
require 'composition'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end