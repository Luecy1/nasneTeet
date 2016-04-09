require 'json'
require 'open-uri'
require 'yaml'
require 'twitter'

require 'time'

twconfig = YAML.load(open('config.yaml'))
client = Twitter::REST::Client.new do |config|
 config.consumer_key = twconfig['consumer_key']
 config.consumer_secret = twconfig['consumer_secret']
 config.access_token = twconfig['access_token']
 config.access_token_secret = twconfig['access_token_secret']
end

while true do

begin

url = 'http://192.168.0.11:64220/schedule/reservedListGet?searchCriteria=0&filter=0&startingIndex=0&requestedCount=0&sortCriteria=0&withDescriptionLong=0&withUserData=1'
#url = 'reservedListGet.json' #LocalTest用
data = JSON.load(open(url).read)

#初期表示時、時間と逆なので反転
data['item'].reverse!

today = Date.today
todaydata = Array.new

data['item'].each do |x|
  date = Date.parse(x['startDateTime'])

  if date == today then
    time = Time.parse(x['startDateTime'])

    if Time.now < time then
      todaydata << x
    end
  end
end

todaydata.each do |x|
  cleanTitle = x['title']
    .gsub(/\ue192/,"【再】")
    .gsub(/\ue195/,"【終】")
    .gsub(/\ue0fe/,"【字】")
    .gsub(/\ue180/,"【デ】")
    .gsub(/\ue184/,"【解】")
    .gsub(/\ue183/,"【多】")
    .gsub(/\ue193/,"【新】")
  time = Time.parse(x['startDateTime']) - Time.now

  #sleep
  if time > 0 then
    sleep time
    client.update("【#{x['channelName']}】#{cleanTitle}　を録画中 #nasne")
  elsif time > -60 then
    client.update("【#{x['channelName']}】#{cleanTitle}　を録画中 #nasne")
  end

end#todaydata

rescue => e
  puts e.message
  exit
end

# 日付変わるまで待機
sleep Time.parse("24:00") - Time.now
end#while
