# frozen_string_literal: true

require 'redis'

if ENV['REDIS_URL']
  uri = URI.parse(ENV['REDIS_URL'])
  REDIS = Redis.current = Redis.new(
    host: uri.host,
    port: uri.port,
    password: uri.password,
    timeout: 10
  )
else
  uri = URI.parse('redis://localhost:6379')
  REDIS = Redis.current = Redis.new(
    host: uri.host,
    port: uri.port,
    password: uri.password,
    db: 15 - (ENV['APP_ENV'] == 'test' ? 1 : 0) - ENV['TEST_ENV_NUMBER'].to_i
  )
end
