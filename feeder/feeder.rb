require_relative 'feed'
require 'response'

class Feeder
  def self.perform(event:, context:)
    feed = Form4Feed.from_sec_rss
    Response.success(feed.to_h)
  end
end