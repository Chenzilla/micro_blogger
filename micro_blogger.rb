require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
  attr_reader :client

  def run
    puts 'Welcome to the Chenzilla Twitter Client!'
    command = ''
    while command != 'q'
      printf 'enter command:'
      input = gets.chomp!
      parts = input.split(' ')
      command = parts[0]

      case command
      when 'q' then puts 'Goodbye!'
      when 't' then tweet(parts[1..-1].join(' '))
      when 'dm' then direct_message(parts[1], parts[2..-1].join(" "))
      when 'spam' then spam_my_followers(parts[1..-1].join(' '))
      when 'elt' then everyones_last_tweet
      when 's' then shorten(parts[1..-1].join(' '))
      when 'turl' then tweet(parts[1..-2].join(' ') + ' ' + shorten(parts[-1]))
      else 
        puts "Sorry, I don't know how to #{command}"
      end
    end
  end

  def initialize
    puts 'Initializing MicroBlogger'
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
    if message.length <= 140
      @client.update(message)
    else
      puts 'Message is longer than 140 characters; please try again.'
    end
  end

  def direct_message(target, message)
    puts "Trying to send #{target} this direct message:"
    puts message

    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    if screen_names.include?(target)
      message = "d @#{target} #{message}"
      tweet(message)  
    else
      puts "Sorry but @#{target} is not following you."
    end
  end

  def followers_list
    screen_names = []
    @client.followers.each do |follower|
      screen_names << @client.user(follower).screen_name
    end
    screen_names
  end

  def spam_my_followers(message)
    followers_list.each do |follower|
      direct_message(follower, message)
    end
  end

  def everyones_last_tweet
    friends = @client.friends
    friends = friends.map { |friend| @client.user(friend) }
    friends.sort_by! { |friend| friend.screen_name.downcase}
   
    friends.each do |friend|
      timestamp = friend.status.created_at.strftime('%A, %b %d')
      tweet = friend.status.text
      puts "@#{friend.screen_name} said..."
      printf "#{tweet} at #{timestamp}"
      puts ''
    end
  end

  def shorten(original_url)
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    short_url = bitly.shorten(original_url).short_url
    puts "Shortening this URL: #{original_url} into #{short_url}"
    short_url
  end 
end

blogger = MicroBlogger.new
blogger.run