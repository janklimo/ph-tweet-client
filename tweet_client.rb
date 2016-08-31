#!/usr/bin/env ruby

require 'bundler/setup'
require 'twitter'
require 'httparty'
require 'imgkit'
require_relative 'utils'

def run(subject:, rank:)
  # initiates twitter client as @client
  init_client

  date = (Date.today - 1).to_s
  response =
    HTTParty.get("https://tophuntsdaily.herokuapp.com/charts/#{date}/data")
  entry_data = JSON.parse(response.body)

  post = entry_data['posts'].find { |p| p['rank'] == rank }
  rank = post['rank']
  hunter = post['hunter']
  makers = post['makers']
  url = post['url']

  image_kit = IMGKit.new(
    "https://tophuntsdaily.herokuapp.com/charts/#{date}?rank=#{rank}",
    zoom: 2, width: 2048, height: 1024
  )
  img = image_kit.to_file("rank_#{rank}_img.jpg")

  case subject
  when 'summary'
    # send summary tweet
    @client.update_with_media(summary_text(entry_data['makers']), img)
    # add makers and hunters to respective twitter lists
    add_list_members(hunters: entry_data['hunters'],
                     makers: entry_data['makers'])
  when 'hunter'
    # hunter tweet
    if hunter.length > 0
      @client.update_with_media(hunter_text(hunter, rank, url), img)
    end
  when 'makers'
    # makers tweet
    if makers.any?
      @client.update_with_media(makers_text(makers, rank, url), img)
    end
  end
end

if $0 == __FILE__
  raise ArgumentError, "Usage: #{$0} subject rank" unless ARGV.length > 0
  run(subject: ARGV[0], rank: (ARGV[1] || 1).to_i)
end
