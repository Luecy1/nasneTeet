require 'json'
require 'open-uri'
require 'yaml'
require 'twitter'

require 'time'


def pickEffectData(data)
  # dataの空チェック
  if data['item'].empty? then
    return nil
  end

  #最後を取得
  lastData = data['item'].pop
  
  #有効かチェックし有効でない場合ばもう一度求める。
  if  lastData['eventId'] == 65536
    return pickEffectData(data)
  end

  #有効である場合、それを返す
  return lastData
end

twconfig = YAML.load(open('config.yaml'))
client = Twitter::REST::Client.new do |config|
 config.consumer_key = twconfig['consumer_key']
 config.consumer_secret = twconfig['consumer_secret']
 config.access_token = twconfig['access_token']
 config.access_token_secret = twconfig['access_token_secret']
end
while true do

begin

url = 'http://192.168.0.13:64220/schedule/reservedListGet?searchCriteria=0&filter=0&startingIndex=0&requestedCount=0&sortCriteria=0&withDescriptionLong=0&withUserData=1'
#url = 'reservedListGet.json' #LocalTest用
data = JSON.load(open(url).read)

#最後を取得
lastData = pickEffectData(data)

#最後を取得できなかった場合24時までsleep
if lastData == nil then
  sleep Time.parse("24:00") - Time.now
  next
end

cleanTitle = lastData['title']
  .gsub(/\ue192/,"【再】")
  .gsub(/\ue195/,"【終】")
  .gsub(/\ue0fe/,"【字】")
  .gsub(/\ue180/,"【デ】")
  .gsub(/\ue184/,"【解】")
  .gsub(/\ue183/,"【多】")
  .gsub(/\ue193/,"【新】")
time = Time.parse(lastData['startDateTime']) - Time.now

#sleepする
if time > 0 then
  sleep time
  client.update("【#{lastData['channelName']}】#{cleanTitle}　を録画中 #nasne")
  #puts "【#{lastData['channelName']}】#{cleanTitle}　を録画中 #nasne"
  sleep 60
end

rescue => e
  puts e.message
  exit
end

end#while
