# frozen_string_literal: true

RSpec.describe 'Feedback' do
  describe 'POST api/feedbacks' do
    let!(:user1) { FactoryBot.create(:user) }
    let!(:user2) { FactoryBot.create(:user) }
    let!(:post1) { FactoryBot.create(:post) }
    let!(:post2) { FactoryBot.create(:post) }
    let!(:feedback1) { FactoryBot.create(:feedback, owner: user1, feedable: post1) }

    let(:request_params) do
      {
        owner_id: user1.id,
        comment: Faker::Lorem.sentence
      }
    end

    context 'when user_id is passed' do
      it 'should create feedback and return correct response' do
        expect(Feedback.count).to eq(1)

        post "#{ENV.fetch('APP_HOST')}/api/feedbacks", request_params.merge(user_id: user2.id)

        expect(response.code).to eq(200)
        expect(response.headers[:content_type]).to eq('application/json')

        expect(Feedback.count).to eq(2)
        last_feedback = Feedback.last
        expect(last_feedback.owner_id).to eq(request_params[:owner_id])
        expect(last_feedback.comment).to eq(request_params[:comment])
        expect(last_feedback.feedable).to eq(user2)

        body = JSON.parse(response.body)
        success_response = FeedbackSerializer.new([last_feedback, feedback1], is_collection: true).as_json
        expect(body).to eq(success_response)
      end
    end

    context 'when post_id is passed' do
      it 'should create feedback and return correct response' do
        expect(Feedback.count).to eq(1)

        post "#{ENV.fetch('APP_HOST')}/api/feedbacks", request_params.merge(post_id: post2.id)

        expect(response.code).to eq(200)
        expect(response.headers[:content_type]).to eq('application/json')

        expect(Feedback.count).to eq(2)
        last_feedback = Feedback.last
        expect(last_feedback.owner_id).to eq(request_params[:owner_id])
        expect(last_feedback.comment).to eq(request_params[:comment])
        expect(last_feedback.feedable).to eq(post2)

        body = JSON.parse(response.body)
        success_response = FeedbackSerializer.new([last_feedback, feedback1], is_collection: true).as_json
        expect(body).to eq(success_response)
      end

      it 'when feedback is already added by owner to same post then it should return error' do
        expect(Feedback.count).to eq(1)

        post "#{ENV.fetch('APP_HOST')}/api/feedbacks", request_params.merge(post_id: post1.id)

        expect(response.code).to eq(422)
        expect(response.headers[:content_type]).to eq('application/json')

        expect(Feedback.count).to eq(1)

        body = JSON.parse(response.body)
        expect(body).to eq({ 'error' => 'Validation failed: Owner You have already added feedback to this Post' })
      end
    end

    context 'user_id and post_id not passed' do
      it 'should not create feedback and return error' do
        expect(Feedback.count).to eq(1)

        post "#{ENV.fetch('APP_HOST')}/api/feedbacks", request_params

        expect(response.code).to eq(422)
        expect(response.headers[:content_type]).to eq('application/json')

        expect(Feedback.count).to eq(1)

        body = JSON.parse(response.body)
        expect(body).to eq({ 'error' => 'user_id or post_id should be present' })
      end
    end
  end
end
