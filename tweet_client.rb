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

  # initiates twitter client as @client
  init_client

  date = (Date.today - 1).to_s
  response =
    HTTParty.get("https://tophuntsdaily.herokuapp.com/charts/#{date}/data")
  entry_data = JSON.parse(response.body)

  # add makers and hunters to respective twitter lists
  add_list_members(hunters: entry_data['hunters'],
                   makers: entry_data['makers'])

  entry_data['posts'].each do |post|
    rank = post['rank']
    hunter = post['hunter']
    makers = post['makers']
    url = post['url']

    image_kit = IMGKit.new(
      "https://tophuntsdaily.herokuapp.com/charts/#{date}?rank=#{rank}",
       zoom: 2, width: 2048, height: 1024
    )
    img = image_kit.to_file("rank_#{rank}_img.jpg")

    # hunter tweet
    @client.update_with_media(hunter_text(hunter, rank, url), img)

    # makers tweet
    unless makers.empty?
      @client.update_with_media(makers_text(makers, rank, url), img)
    end

    # Summary tweet
    if rank == 1
      @client.update_with_media(summary_text(entry_data['makers']), img)
    end
  end
end

if $0 == __FILE__
  run
end
