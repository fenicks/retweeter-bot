# Retweeter bot

Retweeter bot is a little Ruby script based on Ruby Twitter gem.
The goal is to retweet Tweets with specific #tag and written by trusted users.

Feel free to be inspired by this lines of code and write something more bigger.

## Usage

### Environment variables needed

 * **APP_IGNORE_RETWEET**: ignore retweet if set to `true`.
 * **APP_TOPICS**: topics to watch. List of #tags separated by a coma. Ex.: `#forgedtofight,#Transformers,#ContestOfChampions,#MCoC`.
 * **APP_TRUSTED_USERS**: trusted users for retweets and favorites Tweets. Ex.: `MarvelChampions,ForgedtoFight,kabam`.
 * **TWITTER_CONSUMER_KEY**: Twitter consumer key.
 * **TWITTER_CONSUMER_SECRET**: Twitter consumer secret.
 * **TWITTER_ACCESS_TOKEN**: Twitter access token.
 * **TWITTER_ACCESS_SECRET**: Twitter access secret.

 Go to the tweeter documentation to retrieve your credentials : https://apps.twitter.com

### Running the script

 * `gem install bundler --no-document`
 * `bundle install`
 * `bundle exec ruby ./retweeter.rb`

 Have fun