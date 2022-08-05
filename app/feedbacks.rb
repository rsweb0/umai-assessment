# frozen_string_literal: true

require 'rack/app'
require 'active_record'
Dir['./models/*.rb'].sort.each { |file| require file }
require './config/db_connection'
require './serializers/feedback_serializer'

# Nested Rack Application for Feedbacks endpoints
class App
  # App::Feedbacks
  class Feedbacks < Rack::App
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

    desc 'Add feedback'
    post '/api/feedbacks' do
      if payload['user_id']
        extra_params = { feedable_type: 'User', feedable_id: payload['user_id'] }
      elsif payload['post_id']
        extra_params = { feedable_type: 'Post', feedable_id: payload['post_id'] }
      else
        raise 'user_id or post_id should be present'
      end
      feedback = Feedback.create!(
        payload.slice('owner_id', 'comment').merge(extra_params)
      )

      response.status = 200
      response.headers['Content-Type'] = 'application/json'

      feedbacks = feedback.owner.feedbacks.order(updated_at: :desc)
      FeedbackSerializer.new(feedbacks, is_collection: true).serialized_json
    end
  end
end
