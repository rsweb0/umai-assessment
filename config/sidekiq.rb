# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq-cron'
require 'active_record'
require './config/db_connection'

Dir['./models/*.rb'].sort.each { |file| require file }
Dir['./workers/*.rb'].sort.each { |file| require file }

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end

# config/sidekiq.rb
schedule_file = 'config/schedule.yml'
Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file) && Sidekiq.server?
