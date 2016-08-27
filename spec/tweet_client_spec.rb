require 'spec_helper'
require_relative '../tweet_client'

describe '#run' do
  before do
    @date = (Date.today - 1).to_s
    allow(HTTParty).to receive(:get)
      .with("https://tophuntsdaily.herokuapp.com/charts/#{@date}/data")
      .and_return(double(body: ENTRY_DATA))
    allow_any_instance_of(Twitter::REST::Client)
      .to receive(:update_with_media)
    allow_any_instance_of(Twitter::REST::Client)
      .to receive(:add_list_members)
    allow_any_instance_of(Twitter::REST::Client).to receive(:list_members)
      .with("top-hunters", count: 5000)
      .and_return(double(to_h: { users: [{ screen_name: 'iWozzy' }] }))
    allow_any_instance_of(Twitter::REST::Client).to receive(:list_members)
      .with("top-makers", count: 5000)
      .and_return(double(to_h: { users: [{ screen_name: 'nainish' },
                                         { screen_name: 'adrianeholter' }] }))
    (1..5).each do |i|
      allow(IMGKit).to receive(:new)
        .with("https://tophuntsdaily.herokuapp.com/charts/#{@date}?rank=#{i}",
      zoom: 2, width: 2048, height: 1024)
        .and_return(double(to_file: "rank_#{i}_img"))
    end
  end
  it 'throws an error if no params are given' do
    expect{ run }.to raise_error ArgumentError
  end
  it 'initiates twitter client' do
    expect(Twitter::REST::Client).to receive(:new).and_call_original
    run(subject: 'summary', rank: 1)
  end
  it 'retrieves entry data from server' do
    expect(HTTParty).to receive(:get)
      .with("https://tophuntsdaily.herokuapp.com/charts/#{@date}/data")
    run(subject: 'summary', rank: 1)
  end
  context 'summary' do
    it 'sends the summary tweet' do
      expect_any_instance_of(Twitter::REST::Client)
        .to receive(:update_with_media)
        .with(/#TopHunts.*@producthunt.*RyanKennedy/, 'rank_1_img')
        .exactly(:once)
      run(subject: 'summary', rank: 1)
    end
    it 'adds hunters and makers to twitter lists' do
      expect_any_instance_of(Twitter::REST::Client)
        .to receive(:add_list_members)
        .with('top-makers', ["RyanKennedy", "seannieuwoudt", "bevmerriman",
                             "v_ignatyev", "photomatt"])
        .exactly(:once)
      expect_any_instance_of(Twitter::REST::Client)
        .to receive(:add_list_members)
        .with('top-hunters', ["nagra__", "bentossell", "arunpattnaik"])
        .exactly(:once)
      run(subject: 'summary', rank: 1)
    end
  end
  context 'hunter' do
    it 'sends a tweet to the hunter of #1 post' do
      expect_any_instance_of(Twitter::REST::Client)
        .to receive(:update_with_media)
        .with(/@nagra.*for hunting the #1 product/, 'rank_1_img')
        .exactly(:once)
      run(subject: 'hunter', rank: 1)
    end
    it 'sends a tweet to the hunter of #2 post' do
      expect_any_instance_of(Twitter::REST::Client)
        .to receive(:update_with_media)
        .with(/@iWozzy.*for hunting the #2 product/, 'rank_2_img')
        .exactly(:once)
      run(subject: 'hunter', rank: 2)
    end
    it 'sends a tweet to the hunter of #3 post' do
      expect_any_instance_of(Twitter::REST::Client)
        .to receive(:update_with_media)
        .with(/@bentossel.*for hunting the #3 product/, 'rank_3_img')
        .exactly(:once)
      run(subject: 'hunter', rank: 3)
    end
    it 'sends a tweet to the hunter of #4 post' do
      expect_any_instance_of(Twitter::REST::Client)
        .to receive(:update_with_media)
        .with(/@v_ignatyev.*for hunting the #4 product/, 'rank_4_img')
        .exactly(:once)
      run(subject: 'hunter', rank: 4)
    end
    it 'sends nothing as the hunter of #5 post has no twitter' do
      expect_any_instance_of(Twitter::REST::Client)
        .not_to receive(:update_with_media)
      run(subject: 'hunter', rank: 5)
    end
  end
  context 'makers' do
    it 'sends a tweet to the makers of #1 post' do
      expect_any_instance_of(Twitter::REST::Client)
        .to receive(:update_with_media)
        .with(/@adrianeholter.*for making the #1 product/, 'rank_1_img')
        .exactly(:once)
      run(subject: 'makers', rank: 1)
    end
    it 'sends a tweet to the makers of #2 post' do
      expect_any_instance_of(Twitter::REST::Client)
        .to receive(:update_with_media)
        .with(/@Ryan.*nainish.*for making the #2 product/, 'rank_2_img')
        .exactly(:once)
      run(subject: 'makers', rank: 2)
    end
    it 'sends a tweet to the makers of #3 post' do
      expect_any_instance_of(Twitter::REST::Client)
        .to receive(:update_with_media)
        .with(/@seannie.*bevmer.*for making the #3 product/, 'rank_3_img')
        .exactly(:once)
      run(subject: 'makers', rank: 3)
    end
    it 'sends no tweets for #4 post - no makers' do
      expect_any_instance_of(Twitter::REST::Client)
        .not_to receive(:update_with_media)
      run(subject: 'makers', rank: 4)
    end
    it 'sends a tweet to the makers of #5 post' do
      expect_any_instance_of(Twitter::REST::Client)
        .to receive(:update_with_media)
        .with(/@photo.*for making the #5 product/, 'rank_5_img')
        .exactly(:once)
      run(subject: 'makers', rank: 5)
    end
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
         "hunter":"",
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
         "makers":[],
         "url":"https://www.producthunt.com/tech/crx-extractor?utm_campaign=producthunt-api\u0026utm_medium=api\u0026utm_source=Application%3A+Top+Hunts+Daily+%28ID%3A+3237%29",
         "rank":4
      }
   ]
}
JSON
