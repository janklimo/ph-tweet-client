ACTIONS = ['👍', '👏']
THINGS = ['🌟', '🏆', '🏅', '💯', '🚀', '🎉', '😎', '😻']
DRINKS = ['🍾', '🍻']
WORDS = ['Woot', 'Yay', 'Nice', 'Sweet', 'Radical', 'Hurray', 'Epic',
         'Like a boss', 'Whoa', 'Wow']

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

def summary_text(makers_array)
  handles = makers_array.map{ |m| "@#{m}" }.join(' ')
  str = "#TopHunts of #{date_str} on @producthunt #{THINGS.sample(2).join(' ')} " \
    "Products by #{handles} #{ACTIONS.sample}"
  truncate(str, 110)
end

def hunter_text(hunter, rank, url)
  handle = "@#{hunter}"
  str = "#{handle} #{WORDS.sample}! #{ACTIONS.sample} for hunting " \
    "the ##{rank} " \
    "product of #{date_str} on @producthunt! #{DRINKS.sample} " \
    "#{shorten(url)} #{THINGS.sample(2).join(' ')}"
  truncate(str, 110)
end

def makers_text(makers, rank, url)
  return if makers.none?
  handles = makers.map{ |m| "@#{m}" }.join(' ')
  str = "#{handles} #{WORDS.sample}! #{ACTIONS.sample} for making " \
    "the ##{rank} " \
    "product of #{date_str} on @producthunt! #{DRINKS.sample} " \
    "#{shorten(url)} #{THINGS.sample(2).join(' ')}"
  truncate(str, 110)
end