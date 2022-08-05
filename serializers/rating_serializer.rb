# frozen_string_literal: true

require './serializers/base_serializer'

# RatingSerializer
class RatingSerializer < BaseSerializer
  attribute :average_rating do |rating|
    rating.post.average_rating
  end
end
