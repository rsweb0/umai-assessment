# frozen_string_literal: true

require 'nokogiri'
require 'sidekiq'

# FeedbacksXmlFileWorker
class FeedbacksXmlFileWorker
  include Sidekiq::Worker

  def perform
    builder = xml_builder
    filename = "public/#{DateTime.now}_feedbacks.xml"
    File.write(filename, builder.to_xml)
    puts builder.to_xml
  end

  private

  def xml_builder
    feedbacks = ::Feedback.all.includes(:owner, :feedable)
    Nokogiri::XML::Builder.new do |xml|
      xml.root do
        xml.feedbacks do
          feedbacks.find_each do |feedback|
            generate_xml_row(xml, feedback)
          end
        end
      end
    end
  end

  def generate_xml_row(xml, feedback)
    xml.feedback do
      xml.owner_login feedback.owner.email
      xml.user_comment feedback.comment
      xml.rating rating(feedback)
      xml.feedable_type feedback.feedable_type
    end
  end

  def rating(feedback)
    return nil if feedback.feedable_type == 'User'

    ratings[feedback.feedable_id]
  end

  def ratings
    @ratings ||= ::Rating.group(:post_id).select('post_id, AVG(value) AS average_value')
                         .to_h { |rating| [rating.post_id, rating.average_value.round(2).to_f] }
  end
end
