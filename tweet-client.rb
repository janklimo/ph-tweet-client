#!/usr/bin/env ruby

require 'imgkit'
require 'twitter'

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
end

image_kit = IMGKit.new('https://ph-tweet-server.herokuapp.com/charts/2016-08-21?rank=2',
                       zoom: 2, width: 2048, height: 1024)

puts "Saving the preview..."
img = image_kit.to_file('attachment.jpg')

client.update_with_media('👍👏', img)

puts "Done!"
