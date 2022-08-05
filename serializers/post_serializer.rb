# frozen_string_literal: true

require './serializers/base_serializer'

# PostSerializer
class PostSerializer < BaseSerializer
  attributes :title, :content, :author_ip, :user_id
end
