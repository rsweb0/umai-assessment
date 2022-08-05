# frozen_string_literal: true

RSpec.describe 'Seed' do
  it 'Seed should run successfuly and create records' do
    expect(User.count).to eq(0)
    expect(Post.count).to eq(0)
    expect(Feedback.count).to eq(0)
    expect(Rating.count).to eq(0)

    load './seed.rb'

    expect(User.count).to eq(USER_COUNT)
    expect(Post.count).to eq(POST_COUNT)
    expect(Feedback.count).to eq(POST_FEEDBACK_COUNT + USER_FEEDBACK_COUNT)
    expect(Rating.count).to eq(POST_RATING)
  end
end
