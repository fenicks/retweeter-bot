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

@trusted_users = ENV.fetch('APP_TRUSTED_USERS',
                           'ForgedtoFight,MarvelChampions,kabam')
@log.info "[TRUSTED_USERS]: #{@trusted_users}"

begin
  @streamer.filter(track: topics) do |tweet|
    next unless tweet.is_a?(Twitter::Tweet)
    next if 'true'.eql?(ENV['APP_IGNORE_RETWEETS']) && tweet.retweet?
    # Ignore my tweets
    next if tweet.user.id == @client.user(skip_status: true).id
    # Check for trusted users
    next unless @trusted_users.split(',').include?(tweet.user.screen_name)
    action_state = +''
    if 'true'.eql?(ENV['APP_ACTION_RETWEET'])
      @client.retweet!(tweet)
      action_state << '#retweet'
    end
    if 'true'.eql?(ENV['APP_ACTION_FAVORITE'])
      @client.favorite!(tweet)
      action_state << '#favorite'
    end
    @log.info "[TWEET-#{tweet.id}#{action_state}] #{tweet.text}"
  end
rescue Twitter::Error::TooManyRequests => e
  @log.warn "[TOOMANYREQUESTS-START]: #{e}"
  sleep e.rate_limit.reset_in * 1.75
  @log.warn "[TOOMANYREQUESTS-END  ]: #{e}"
  retry
rescue StandardError => e
  @log.warn e
  sleep 5
  retry
end
