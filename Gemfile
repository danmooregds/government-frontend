source "https://rubygems.org"

gem "rails", "6.1.4.7"

gem "dalli"
gem "gds-api-adapters"
gem "govuk_ab_testing"
gem "govuk_app_config", git: "https://github.com/alphagov/govuk_app_config.git", branch: "main"
gem "govuk_personalisation"
gem "govuk_publishing_components"
gem "htmlentities"
gem "plek"
gem "rack_strip_client_ip"
gem "rails-controller-testing"
gem "rails-i18n"
gem "sassc-rails"
gem "slimmer"
gem "uglifier"

group :development, :test do
  gem "govuk_schemas"
  gem "govuk_test"
  gem "jasmine"
  gem "jasmine_selenium_runner"
  gem "rails_translation_manager"
  gem "rubocop-govuk"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "pry"
end

group :test do
  gem "capybara"
  gem "faker"
  gem "i18n-coverage"
  gem "minitest-reporters"
  gem "mocha"
  gem "simplecov"
  gem "timecop"
  gem "webmock", require: false
end
