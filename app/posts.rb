# frozen_string_literal: true

require 'rack/app'
require 'active_record'
Dir['./models/*.rb'].sort.each { |file| require file }
require './config/db_connection'
require './serializers/post_serializer'

# Nested Rack Application for Posts endpoints
class App
  # App::Posts
  class Posts < Rack::App
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

    desc 'Get Top N Posts'
    get '/api/posts' do
      response.headers['Content-Type'] = 'application/json'
      top_n_posts = params['number_of_posts'] || 10

      posts = Post.left_outer_joins(:ratings).group('posts.id')
                  .order('AVG(ratings.value) desc NULLS LAST')
                  .select('posts.id, posts.title, posts.content')
                  .limit(top_n_posts)
      PostSerializer.new(posts, is_collection: true, fields: { post: %i[title content] }).serialized_json
    end

    desc 'Create a new Post'
    post '/api/posts' do
      ActiveRecord::Base.transaction do
        res = User.authenticate(payload['email'], payload['password'])
        if res[:success]
          user = res[:user]
        elsif res[:error_code] == :user_not_found
          user = User.create!(payload.slice('email', 'password'))
        else
          raise 'Invalid password for user!'
        end

        post = Post.create!(
          payload.slice('title', 'content').merge(
            user: user,
            author_ip: request.ip
          )
        )

        response.status = 200
        response.headers['Content-Type'] = 'application/json'

        PostSerializer.new(post).serialized_json
      end
    end

    desc 'Get a list of IPs from which several different authors posted.'
    get '/api/posts/authors' do
      posts = Post.joins(:user)
                  .group('author_ip, users.id')
                  .select('author_ip, users.email as email')

      res = posts.map { |p| [p.author_ip, p.email] }
                 .group_by(&:shift)
                 .transform_values(&:flatten)
                 .transform_values(&:sort).to_a

      response.status = 200
      response.headers['Content-Type'] = 'application/json'
      res.to_json
    end
  end
end
