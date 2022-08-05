# frozen_string_literal: true

RSpec.describe 'Ratings' do
  describe 'POST api/ratings' do
    let!(:post1) { FactoryBot.create(:post) }
    let!(:rating1) { FactoryBot.create(:rating, post: post1, value: 5) }

    let(:request_params) do
      {
        post_id: post1.id,
        value: 3
      }
    end

    it 'with valid parameters should create user and post' do
      expect(Rating.count).to eq(1)

      post "#{ENV.fetch('APP_HOST')}/api/ratings", request_params

      expect(response.code).to eq(200)
      expect(response.headers[:content_type]).to eq('application/json')

      expect(Rating.count).to eq(2)

      body = JSON.parse(response.body)
      expect(body).to eq({ 'average_rating' => 4.0 })
    end

    it 'with missing parameters should not create rating and return error' do
      expect(Rating.count).to eq(1)

      post "#{ENV.fetch('APP_HOST')}/api/ratings", request_params.slice(:post_id)

      expect(response.code).to eq(422)
      expect(response.headers[:content_type]).to eq('application/json')

      expect(Rating.count).to eq(1)

      body = JSON.parse(response.body)
      expect(body).to eq({ 'error' => 'Validation failed: Value is not included in the list' })
    end
  end
end
