# frozen_string_literal: true

require 'json'
require 'rack/app'
require './config/db_connection'

# Top-Level Rack Application
class App < Rack::App
  headers 'Access-Control-Allow-Origin' => '*'

  serializer do |obj|
    if obj.is_a?(String)
      obj
    else
      JSON.dump(obj)
    end
  end

  error StandardError, NoMethodError do |ex|
    response.status = 500
    { error: ex.message }
  end

  desc 'Microprofile Health endpoint'
  get '/health' do
    response.headers['Content-Type'] = 'application/json'

    { status: 'UP' }
  end

  Dir['./app/*.rb'].sort.each { |file| require file }

  mount App::Posts, to: '/'
  mount App::Ratings, to: '/'
  mount App::Feedbacks, to: '/'
end

run App
