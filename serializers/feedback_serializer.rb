# frozen_string_literal: true

require './serializers/base_serializer'

# FeedbackSerializer
class FeedbackSerializer < BaseSerializer
  attributes :feedable_type, :feedable_id, :owner_id, :comment, :created_at, :updated_at
end
