ACTIONS = ['👍', '👏']
THINGS = ['🌟', '🏅', '💯', '🚀', '🎉', '😎', '😻', '🤘']
DRINKS = ['🍾', '🍻']
WORDS = ['Woot', 'Yay', 'Nice', 'Sweet', 'Radical', 'Hurray', 'Epic',
         'Like a boss', 'Whoa', 'Wow']
# every URL longer than 23 characters gets shortened to 23 characters
# https://support.twitter.com/articles/78124
URL_LENGTH = 23

# loosely borrowing this from Rails :)
def truncate(str, truncate_at, options = {})
  return str unless str.length > truncate_at

  options[:separator] ||= ' '
  stop = str.rindex(options[:separator], truncate_at) || truncate_at

  "#{str[0, stop]}"
end

def shorten(str)
  str.gsub(/\?.*/, '')
end

def date_str
  (Date.today - 1).strftime("%b %-d, %Y")
end

def init_client
  @client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
  end
end

# Daily summary tweet sent once. Example:
# #TopHunts of Apr 13, 2017 on @producthunt 🤘🌟 Products by @halfdanj
# @nookajones @andraskindler @zsedbal @bncbgr 🏆 https://www.producthunt.com/posts/dropunited
# We attempt to fit as many makers in while keeping the rest of the tweet fixed
def summary_text(makers_array, winner_url)
  # 1. text
  # 2. handles
  # 3. text
  # 4. URL
  handles = makers_array.map{ |m| "@#{m}" }.join(' ')
  text_1 = "#TopHunts of #{date_str} on @producthunt #{THINGS.sample(2).join} Products by "
  text_3 = " 🏆 "
  limit_for_handles = 140 - [text_1, text_3].join.length - URL_LENGTH
  tweet = "#{text_1}#{truncate(handles, limit_for_handles)}#{text_3}" \
    "#{shorten(winner_url)}"
  puts tweet
  tweet
end

# A tweet sent to every hunter. Example:
# @picsoung Epic! 👏 for hunting the #5 product of Apr 13, 2017 on @producthunt!
# 🍻 https://www.producthunt.com/posts/facebook-for-slack-by-mailclark🤘🌟
# this is only ever ~110 characters long so no need to truncate
def hunter_text(hunter, rank, url)
  handle = "@#{hunter}"
  tweet = "#{handle} #{WORDS.sample}! #{ACTIONS.sample} for hunting " \
    "the ##{rank} " \
    "product of #{date_str} on @producthunt! #{DRINKS.sample} " \
    "#{shorten(url)} #{THINGS.sample(2).join}"
  puts tweet
  tweet
end

# This sends a tweet mentioning all the makers, so it's important to truncate
# their list while keeping the rest of the tweet fixed. Example:
# @andraskindler @zsedbal @bncbgr Like a boss! 👍 for making the #3 product of
# Apr 13, 2017 on @producthunt! 🍻 https://www.producthunt.com/posts/hpstr 😎😻
def makers_text(makers, rank, url)
  # 1. handles
  # 2. text
  # 3. URL
  # 4. text
  return if makers.none?
  handles = makers.map{ |m| "@#{m}" }.join(' ')
  text_2 = " #{WORDS.sample}! #{ACTIONS.sample} for making the ##{rank} " \
    "product of #{date_str} on @producthunt! #{DRINKS.sample} "
  text_4 = " #{THINGS.sample(2).join}"
  limit_for_handles = 140 - [text_2, text_4].join.length - URL_LENGTH
  tweet = "#{truncate(handles, limit_for_handles)}#{text_2}" \
    "#{shorten(url)}#{text_4}"
  puts tweet
  tweet
end

def add_list_members(hunters:, makers:)
  existing_hunters = @client.list_members('top-hunters', count: 5000)
    .to_h[:users].map { |u| u[:screen_name] }
  @client.add_list_members('top-hunters', hunters - existing_hunters)

  existing_makers = @client.list_members('top-makers', count: 5000)
    .to_h[:users].map { |u| u[:screen_name] }
  @client.add_list_members('top-makers', makers - existing_makers)
end
