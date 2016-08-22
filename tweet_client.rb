#!/usr/bin/env ruby

require 'httparty'
require 'imgkit'
require 'twitter'

# TODO:
# send tweets to makers and hunters
# add hunters to list
# add makers to list
# update Twitter description

ACTIONS = ['👍', '👏']
THINGS = ['🌟', '🏆', '🏅', '💯', '🚀']
DRINKS = ['🍾', '🍻']

# borrowing this from Rails :)
def truncate(str, truncate_at, options = {})
  return str unless str.length > truncate_at

  options[:separator] ||= ' '
  stop = str.rindex(options[:separator], truncate_at) || truncate_at

  "#{str[0, stop]}"
end

def summary_text(makers_array)
  date_str = (Date.today - 1).strftime("%b %-d, %Y")
  handles = makers_array.map{ |m| "@#{m}" }.join(' ')
  str = "#TopHunts of #{date_str} on @producthunt #{THINGS.sample(2).join(' ')} " \
    "Products by #{handles} #{ACTIONS.sample}"
  truncate(str, 110)
end

def run
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
  end

  date = (Date.today - 1).to_s
  response =
    HTTParty.get("https://ph-tweet-server.herokuapp.com/charts/#{date}/data")
  entry_data = JSON.parse(response.body)

  image_kit = IMGKit.new("https://ph-tweet-server.herokuapp.com/charts/#{date}",
                         zoom: 2, width: 2048, height: 1024)
  rank_1_img = image_kit.to_file('rank_1_img.jpg')

  # Summary tweet
  client.update_with_media(summary_text(entry_data['makers']), rank_1_img)

  entry_data['posts'].each do |post|

  end
end

if $0 == __FILE__
  run
end
