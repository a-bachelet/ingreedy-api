# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.1'

# Base
gem 'bootsnap', require: false
gem 'pg', '~> 1.5'
gem 'puma', '>= 5.0'
gem 'rails', '~> 7.1.3', '>= 7.1.3.3'
gem 'redis', '~> 5.2'
gem 'sqlite3', '~> 1.4'
gem 'tzinfo-data', platforms: %i[windows jruby]

group :development do
  gem 'annotate', '~> 3.2'
  gem 'bundler-audit', '~> 0.9.1'
  gem 'dockerfile-rails', '>= 1.6'
  gem 'reek', '~> 6.3'
end

group :test do
  gem 'capybara', '~> 3.40'
  gem 'simplecov', '~> 0.22.0'
end

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'dotenv', '~> 3.1'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'rspec-rails', '~> 6.1'
  gem 'rubocop', '~> 1.64'
  gem 'rubocop-capybara', '~> 2.21'
  gem 'rubocop-factory_bot', '~> 2.26'
  gem 'rubocop-rails', '~> 2.25'
  gem 'rubocop-rspec', '~> 2.31'
  gem 'rubocop-rspec_rails', '~> 2.29'
end
