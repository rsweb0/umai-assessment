# frozen_string_literal: true

require 'faker'
require 'active_record'
Dir['./models/*.rb'].sort.each { |file| require file }
require './config/db_connection'
require 'activerecord-import/base'
require 'activerecord-import/active_record/adapters/postgresql_adapter'
require 'benchmark'

BATCH_SIZE = 2000
USER_COUNT = 100
POST_COUNT = 200_000
POST_FEEDBACK_COUNT = 10_000
USER_FEEDBACK_COUNT = 50
POST_RATING = 0

# rubocop:disable Metrics/BlockLength
time = Benchmark.measure do
  user_time = Benchmark.measure do
    puts "#{USER_COUNT} users creation started..."

    # User create
    user_values = []
    USER_COUNT.times do |i|
      user_values << User.new(email: "umai_user+#{i + 1}@umai.com", password: 'password')
    end
    User.import user_values, validate: false, batch_size: BATCH_SIZE
    puts "#{USER_COUNT} users created"
  end
  puts user_time

  sleep(2)

  post_time = Benchmark.measure do
    # Post create
    puts "#{POST_COUNT} posts creation started..."

    # 50 unique ips
    author_ips = (0..49).map do |_i|
      Faker::Internet.unique.ip_v4_address
    end

    post_columns = %i[user_id title content author_ip]
    post_values = []
    post_count_per_user = POST_COUNT / USER_COUNT
    User.last(USER_COUNT).each_with_index do |user, i|
      post_count_per_user.times do |_j|
        post_values << [user.id, Faker::Lorem.word, Faker::Lorem.paragraph, author_ips[i % 50]]
      end
    end
    Post.import post_columns, post_values, validate: false, batch_size: BATCH_SIZE
    puts "#{POST_COUNT} posts created"
  end
  puts post_time

  sleep(2)

  feedback_time = Benchmark.measure do
    # Feedback create
    puts "#{POST_FEEDBACK_COUNT} posts feedback creation started..."
    feedback_columns = %i[feedable_type feedable_id owner_id comment]
    feedback_values = []
    post_feedback_per_user = POST_FEEDBACK_COUNT / USER_COUNT

    posts = Post.last(POST_FEEDBACK_COUNT)
    j = 0
    User.last(USER_COUNT).each_with_index do |user, _i|
      post_feedback_per_user.times do
        feedback_values << ['Post', posts[j].id, user.id, Faker::Lorem.sentence]
        j += 1
      end
    end
    Feedback.import feedback_columns, feedback_values, validate: false, batch_size: BATCH_SIZE

    feedback_values = []

    users = User.last(USER_FEEDBACK_COUNT)

    USER_FEEDBACK_COUNT.times do |i|
      feedback_values << ['User', users[i].id, users[USER_FEEDBACK_COUNT - i - 1].id, Faker::Lorem.sentence]
    end
    Feedback.import feedback_columns, feedback_values, validate: false, batch_size: BATCH_SIZE

    puts "#{POST_FEEDBACK_COUNT} posts feedback created"
    puts "#{USER_FEEDBACK_COUNT} users feedback created"
  end
  puts feedback_time

  sleep(2)

  rating_time = Benchmark.measure do
    # Ratings create
    puts "#{POST_RATING} posts rating creation started..."
    rating_columns = %i[post_id value]
    rating_values = []
    total_posts_rated = 0

    Post.last(POST_RATING).each do |post|
      ratings_to_build = rand(1..100)

      ratings_to_build.times do
        total_posts_rated += 1
        break if total_posts_rated > POST_RATING

        rating_values << [post.id, rand(1..5)]
      end
      break if total_posts_rated > POST_RATING
    end
    Rating.import rating_columns, rating_values, validate: false, batch_size: BATCH_SIZE
  end
  puts rating_time
end
puts time
# rubocop:enable Metrics/BlockLength
