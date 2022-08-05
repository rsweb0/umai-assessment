# frozen_string_literal: true

require 'rack/app'
require 'active_record'
Dir['./models/*.rb'].sort.each { |file| require file }
require './config/db_connection'

# Nested Rack Application for Ratings endpoints
class App
  # App::Ratings
  class Ratings < Rack::App
    payload do
      parser do
        accept :json, :www_form_urlencoded
        reject_unsupported_media_types
      end
    end

    error StandardError, NoMethodError do |ex|
      response.status = 422
      response.headers['Content-Type'] = 'application/json'
      puts ex
      puts ex.backtrace.join("\n")
      { error: ex.message }.to_json
    end

    desc 'Rate the post'
    post '/api/ratings' do
      rating = Rating.create!(payload.slice('post_id', 'value'))

      response.status = 200
      response.headers['Content-Type'] = 'application/json'

      { average_rating: rating.post.average_rating }.to_json
    end
  end
end
