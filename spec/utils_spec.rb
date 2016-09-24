require 'spec_helper'
require_relative '../tweet_client'
require_relative '../utils'

describe '#truncate' do
  it 'returns string if it is shorter than truncate_at' do
    expect(truncate('My string', 20)).to eq('My string')
  end
  it 'truncates a long string respecting spaces' do
    expect(truncate('One Two Three Four', 10)).to eq('One Two')
  end
  it 'can handle emoji' do
    expect(truncate('👍👏 more text', 10)).to eq '👍👏 more'
  end
end

describe '#shorten' do
  it 'returns trimmed version of the link' do
    expect(shorten('www.google.com?this')).to eq 'www.google.com'
  end
  it 'returns the same string if there is no ?' do
    expect(shorten('nothing to shorten')).to eq 'nothing to shorten'
  end
end

describe '#summary_text' do
  it 'renders the text' do
    expect(summary_text(['a', 'b']).length).to be <= LIMIT
  end
  it 'truncates a really long list of makers' do
    makers = (1..15).map { |i| "maker#{i}" }
    expect(summary_text(makers).length).to be <= LIMIT
    expect(summary_text(makers)).to include Time.now.year.to_s
    expect(summary_text(makers)).to include '@maker2'
  end
end

describe '#hunter_text' do
  it 'renders the right text' do
    url = 'https://www.producthunt.com/tech/plug-3?utm_campaign=producthunt-api'
    text = hunter_text('jon', '3', url)
    expect(text).to include '@jon'
    expect(text).to include 'for hunting'
    expect(text).to include '#3'
    expect(text.length).to be <= (LIMIT + shorten(url).length)
    expect(text).to match(/https:\/\/www.producthunt.com\/tech\/plug-3\s/)
  end
end

describe '#makers_text' do
  it 'handles multiple makers' do
    makers = (1..15).map { |i| "maker#{i}" }
    url = 'https://www.producthunt.com/tech/plug-3?utm_campaign=producthunt-api'
    text = makers_text(makers, '3', url)
    expect(text).to include '@maker1 @maker2 @maker3 @maker4'
    expect(text).to include 'for making'
    expect(text).to include '#3'
    expect(text.length).to be <= (LIMIT + shorten(url).length)
    expect(text).to match(/https:\/\/www.producthunt.com\/tech\/plug-3\s/)
  end
  it 'returns empty string if no makers are given' do
    arr = []
    text = makers_text(arr, '3', 'www.link.com?param')
    expect(text).to eq nil
  end
end
