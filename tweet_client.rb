#!/usr/bin/env ruby

require 'bundler/setup'
require 'twitter'
require 'httparty'
require 'imgkit'
require_relative 'utils'

# TODO:
# update Twitter description
# show table on server

def run
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
  end

  # TODO
  # add hunters and makers to list
  # p client.list_members('top-makers', count: 5000)
  #   .to_h[:users].map { |u| u[:screen_name] }
  # client.add_list_members('top-makers', ['janklimo'])

  date = (Date.today - 1).to_s
  response =
    HTTParty.get("https://ph-tweet-server.herokuapp.com/charts/#{date}/data")
  entry_data = JSON.parse(response.body)

  entry_data['posts'].each do |post|
    rank = post['rank']
    hunter = post['hunter']
    makers = post['makers']
    url = post['url']

    image_kit = IMGKit.new(
      "https://ph-tweet-server.herokuapp.com/charts/#{date}?rank=#{rank}",
       zoom: 2, width: 2048, height: 1024
    )
    img = image_kit.to_file("rank_#{rank}_img.jpg")

    # hunter tweet
    client.update_with_media(hunter_text(hunter, rank, url), img)

    # makers tweet
    unless makers.empty?
      client.update_with_media(makers_text(makers, rank, url), img)
    end

    # Summary tweet
    if rank == 1
      client.update_with_media(summary_text(entry_data['makers']), img)
    end
  end
end

if $0 == __FILE__
  run
end
