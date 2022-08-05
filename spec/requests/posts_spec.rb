# frozen_string_literal: true

RSpec.describe 'Posts' do
  describe 'GET api/posts' do
    let!(:post1) { FactoryBot.create(:post) }
    let!(:post2) { FactoryBot.create(:post) }
    let!(:post3) { FactoryBot.create(:post) }
    let!(:post4) { FactoryBot.create(:post) }
    let!(:post5) { FactoryBot.create(:post) }
    let!(:rating1) { FactoryBot.create(:rating, value: 5, post: post3) }
    let!(:rating2) { FactoryBot.create(:rating, value: 3, post: post1) }
    let!(:rating3) { FactoryBot.create(:rating, value: 1, post: post2) }

    let!(:success_response) { PostSerializer.new([post3, post1, post2], is_collection: true, fields: { post: %i[title content] }).as_json }

    it 'should return correct top n posts as json response' do
      get "#{ENV.fetch('APP_HOST')}/api/posts", params: { number_of_posts: 3 }

      expect(response.code).to eq(200)
      expect(response.headers[:content_type]).to eq('application/json')
      body = JSON.parse(response.body)
      expect(body['data'].size).to eq(3)
      expect(body).to eq(success_response)
    end

    it 'should return correct top n posts as json response' do
      get "#{ENV.fetch('APP_HOST')}/api/posts", params: { number_of_posts: 4 }

      expect(response.code).to eq(200)
      expect(response.headers[:content_type]).to eq('application/json')
      body = JSON.parse(response.body)
      expect(body['data'].size).to eq(4)
    end
  end

  describe 'POST api/posts' do
    let(:request_params) do
      {
        email: 'umai_test_user@umai.com',
        password: 'testpass',
        title: Faker::Lorem.word,
        content: Faker::Lorem.paragraph
      }
    end

    context 'when user is not registered' do

      it 'should create user and post' do
        expect(User.count).to eq(0)
        expect(Post.count).to eq(0)

        post "#{ENV.fetch('APP_HOST')}/api/posts", request_params

        expect(response.code).to eq(200)
        expect(response.headers[:content_type]).to eq('application/json')

        expect(User.count).to eq(1)
        expect(Post.count).to eq(1)

        body = JSON.parse(response.body)['data']
        expect(body['attributes']['title']).to eq(request_params[:title])
        expect(body['attributes']['content']).to eq(request_params[:content])
        expect(body['attributes']['author_ip']).not_to be_blank
        expect(body['attributes']['user_id']).to eq(User.first.id)
      end
    end

    context 'when user is registered with correct password' do
      let!(:user) { FactoryBot.create(:user, email: request_params[:email], password: request_params[:password]) }

      it 'should use existing user and create new post' do
        expect(User.count).to eq(1)
        expect(Post.count).to eq(0)

        post "#{ENV.fetch('APP_HOST')}/api/posts", request_params

        expect(response.code).to eq(200)
        expect(response.headers[:content_type]).to eq('application/json')

        expect(User.count).to eq(1)
        expect(Post.count).to eq(1)

        body = JSON.parse(response.body)['data']
        expect(body['attributes']['title']).to eq(request_params[:title])
        expect(body['attributes']['content']).to eq(request_params[:content])
        expect(body['attributes']['author_ip']).not_to be_blank
        expect(body['attributes']['user_id']).to eq(user.id)
      end
    end

    context 'when user is registered with incorrect password' do
      let!(:user) { FactoryBot.create(:user, email: request_params[:email], password: 'invalid_password') }

      it 'should not create user or post and return error' do
        expect(User.count).to eq(1)
        expect(Post.count).to eq(0)

        post "#{ENV.fetch('APP_HOST')}/api/posts", request_params

        expect(response.code).to eq(422)
        expect(response.headers[:content_type]).to eq('application/json')

        expect(User.count).to eq(1)
        expect(Post.count).to eq(0)

        body = JSON.parse(response.body)
        expect(body).to eq({ 'error' => 'Invalid password for user!' })
      end
    end

    context 'when user is not registered with missing post values' do
      it 'should not create user or post and return error' do
        expect(User.count).to eq(0)
        expect(Post.count).to eq(0)

        post "#{ENV.fetch('APP_HOST')}/api/posts", request_params.slice(:email, :password)

        expect(response.code).to eq(422)
        expect(response.headers[:content_type]).to eq('application/json')

        expect(User.count).to eq(0)
        expect(Post.count).to eq(0)

        body = JSON.parse(response.body)
        expect(body).to eq({ 'error' => "Validation failed: Title can't be blank, Content can't be blank" })
      end
    end
  end

  describe 'GET api/posts/authors' do
    let!(:ip1) { Faker::Internet.unique.ip_v4_address }
    let!(:ip2) { Faker::Internet.unique.ip_v4_address }
    let!(:user1) { FactoryBot.create(:user) }
    let!(:user2) { FactoryBot.create(:user) }
    let!(:post1) { FactoryBot.create(:post, author_ip: ip1, user: user1) }
    let!(:post2) { FactoryBot.create(:post, author_ip: ip1, user: user1) }
    let!(:post3) { FactoryBot.create(:post, author_ip: ip1, user: user2) }
    let!(:post4) { FactoryBot.create(:post, author_ip: ip2, user: user1) }
    let!(:success_response) { [[ip1, [user1.email, user2.email].sort], [ip2, [user1.email]]] }

    it 'should return correct response' do
      get "#{ENV.fetch('APP_HOST')}/api/posts/authors"

      expect(response.code).to eq(200)
      expect(response.headers[:content_type]).to eq('application/json')
      body = JSON.parse(response.body)
      expect(body).to match_array(success_response)
    end
  end
end
