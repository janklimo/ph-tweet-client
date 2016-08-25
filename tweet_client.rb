#!/usr/bin/env ruby

require 'bundler/setup'
require 'twitter'
require 'httparty'
require 'imgkit'
require_relative 'utils'

def run

  # initiates twitter client as @client
  init_client

  date = (Date.today - 1).to_s
  response =
    HTTParty.get("https://tophuntsdaily.herokuapp.com/charts/#{date}/data")
  entry_data = JSON.parse(response.body)

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
    begin
      @client.update_with_media(hunter_text(hunter, rank, url), img)
    rescue Twitter::Error::RequestTimeout
      sleep 15
      retry
    end

    # makers tweet
    unless makers.empty?
      begin
        @client.update_with_media(makers_text(makers, rank, url), img)
      rescue Twitter::Error::RequestTimeout
        sleep 15
        retry
      end
    end

    # Summary tweet
    if rank == 1
      begin
        @client.update_with_media(summary_text(entry_data['makers']), img)
      rescue Twitter::Error::RequestTimeout
        sleep 15
        retry
      end
    end
  end

  # add makers and hunters to respective twitter lists
  add_list_members(hunters: entry_data['hunters'],
                   makers: entry_data['makers'])
end

if $0 == __FILE__
  run
end
