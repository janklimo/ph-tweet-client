require 'spec_helper'
require 'rspec/mocks'
require 'rspec/expectations'
require_relative '../tweet_client'

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

describe '#summary_text' do
  it 'renders the text' do
    expect(summary_text(['a', 'b']).length).to be <= 115
  end
  it 'truncates a really long list of makers' do
    makers = (1..15).map { |i| "maker#{i}" }
    expect(summary_text(makers).length).to be <= 110
    expect(summary_text(makers)).to include Time.now.year.to_s
    expect(summary_text(makers)).to include '@maker2'
  end
end

describe '#run' do
  before do
    @date = (Date.today - 1).to_s
    allow(HTTParty).to receive(:get)
      .with("https://ph-tweet-server.herokuapp.com/charts/#{@date}/data")
      .and_return(double(body: ENTRY_DATA))
    allow_any_instance_of(Twitter::REST::Client)
      .to receive(:update_with_media)
    allow(IMGKit).to receive(:new)
      .with("https://ph-tweet-server.herokuapp.com/charts/#{@date}",
           zoom: 2, width: 2048, height: 1024)
             .and_return(double(to_file: 'rank_1_img'))
  end
  it 'initiates twitter client' do
    expect(Twitter::REST::Client).to receive(:new).and_call_original
    run
  end
  it 'retrieves entry data from server' do
    expect(HTTParty).to receive(:get)
      .with("https://ph-tweet-server.herokuapp.com/charts/#{@date}/data")
    run
  end
  it 'sends the summary tweet' do
    expect_any_instance_of(Twitter::REST::Client)
      .to receive(:update_with_media)
      .with(/@RyanKennedy/, 'rank_1_img')
    run
  end
end

ENTRY_DATA = <<JSON
{
   "id":2,
   "date":"2016-08-21",
   "makers":[
      "adrianeholter",
      "RyanKennedy",
      "nainish",
      "seannieuwoudt",
      "bevmerriman",
      "v_ignatyev",
      "photomatt"
   ],
   "hunters":[
      "nagra__",
      "iWozzy",
      "bentossell",
      "v_ignatyev",
      "arunpattnaik"
   ],
   "posts":[
      {
         "id":6,
         "hunter":"nagra__",
         "makers":[
            "adrianeholter"
         ],
         "url":"https://www.producthunt.com/tech/html5-speedtest-by-ookla?utm_campaign=producthunt-api\u0026utm_medium=api\u0026utm_source=Application%3A+Top+Hunts+Daily+%28ID%3A+3237%29",
         "rank":1
      },
      {
         "id":10,
         "hunter":"arunpattnaik",
         "makers":[
            "photomatt"
         ],
         "url":"https://www.producthunt.com/tech/get-blog-by-wordpress?utm_campaign=producthunt-api\u0026utm_medium=api\u0026utm_source=Application%3A+Top+Hunts+Daily+%28ID%3A+3237%29",
         "rank":5
      },
      {
         "id":7,
         "hunter":"iWozzy",
         "makers":[
            "RyanKennedy",
            "nainish"
         ],
         "url":"https://www.producthunt.com/tech/hyfy?utm_campaign=producthunt-api\u0026utm_medium=api\u0026utm_source=Application%3A+Top+Hunts+Daily+%28ID%3A+3237%29",
         "rank":2
      },
      {
         "id":8,
         "hunter":"bentossell",
         "makers":[
            "seannieuwoudt",
            "bevmerriman"
         ],
         "url":"https://www.producthunt.com/tech/arthur-2?utm_campaign=producthunt-api\u0026utm_medium=api\u0026utm_source=Application%3A+Top+Hunts+Daily+%28ID%3A+3237%29",
         "rank":3
      },
      {
         "id":9,
         "hunter":"v_ignatyev",
         "makers":[
            "v_ignatyev"
         ],
         "url":"https://www.producthunt.com/tech/crx-extractor?utm_campaign=producthunt-api\u0026utm_medium=api\u0026utm_source=Application%3A+Top+Hunts+Daily+%28ID%3A+3237%29",
         "rank":4
      }
   ]
}
JSON
