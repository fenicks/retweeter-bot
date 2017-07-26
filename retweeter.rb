# frozen_string_literal: true

require 'logger'
require 'twitter'

@log = Logger.new(STDOUT, level: :info).tap { STDOUT.sync = true }

CONFIG = {
  consumer_key: ENV['TWITTER_CONSUMER_KEY'],
  consumer_secret: ENV['TWITTER_CONSUMER_SECRET'],
  access_token: ENV['TWITTER_ACCESS_TOKEN'],
  access_token_secret: ENV['TWITTER_ACCESS_SECRET'],
  proxy: ENV['http_proxy'] || ENV['https_proxy']
}.freeze

@client = Twitter::REST::Client.new CONFIG
@streamer = Twitter::Streaming::Client.new CONFIG

topics = ENV.fetch('APP_TOPICS', '#forgedtofight,#MCoC,#kabam')
@log.info "[TOPICS]: #{topics}"

trusted_users = ENV.fetch('APP_TRUSTED_USERS',
                          'ForgedtoFight,MarvelChampions,kabam')
@log.info "[TRUSTED_USERS]: #{trusted_users}"

@streamer.filter(track: topics) do |object|
  begin
    next unless object.is_a?(Twitter::Tweet)
    # Ignore my tweets
    next if object.user.id == @client.user(skip_status: true).id
    # Check for trusted users
    next unless trusted_users.split(',').include?(object.user.screen_name)
    @client.retweet! object
    @client.favorite! object
    @log.info "[RETWEETED-FAV] #{object.text}"
  rescue => e
    @log.warn e
  end
end
