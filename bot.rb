require 'rubygems'
require 'bundler/setup'
Bundler.require

# Monkey-patch HTTP::URI
class HTTP::URI
  def port
    443 if self.https?
  end
end

class Bot
  def self.go
    while true
      begin
        config = {
          :consumer_key        => ENV['CONSUMER_KEY'],
          :consumer_secret     => ENV['CONSUMER_SECRET'],
          :access_token        => ENV['ACCESS_TOKEN'],
          :access_token_secret => ENV['ACCESS_TOKEN_SECRET']
        }
        rClient = Twitter::REST::Client.new(config)
        sClient = Twitter::Streaming::Client.new(config)

        # topics to watch
        topics = [
          'gonna shake it off',
          'shakeitoff',
          '#blankspacebaby',
          'now we got bad blood',
          #'say you\'ll remember me'
        ]
        sClient.filter(:track => topics.join(',')) do |tweet|
          next if tweet.text.match(/#{rClient.user.screen_name}/i)
          if tweet.is_a?(Twitter::Tweet) && !tweet.text.match(/^RT/) && tweet.lang == 'en'
            reply = "@#{tweet.user.screen_name} "
            p "@#{tweet.user.screen_name}: #{tweet.text} (ID: #{tweet.id}) (#{tweet.lang})"
            if tweet.text.match(/shake/i)
              reply += "You got to!"
            elsif tweet.text.match(/blank/i)
              reply += "I'll write your name!"
            elsif tweet.text.match(/remember/i)
              reply += "Even if it's just in your wildest dreams"
            elsif tweet.text.match(/blood/i)
              reply += "Band-aids don't fix bullet holes"
            else
              next
            end
            rClient.update(reply, :in_reply_to_status_id => tweet.id)
          end
        end
      rescue Exception => e
        seconds = 5
        puts "error occurred, waiting for #{seconds} seconds (#{e.class.to_s})"
        sleep seconds
      end
    end
  end
end
