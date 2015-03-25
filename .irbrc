require 'irb/completion'
require 'irb/ext/save-history'
require 'awesome_print'
require 'pry'
require 'pry-nav'
require 'luffa'

AwesomePrint.irb!

ARGV.concat [ '--readline',
              '--prompt-mode',
              'simple']

IRB.conf[:SAVE_HISTORY] = 100

# Store results in home directory with specified file name
IRB.conf[:HISTORY_FILE] = '.irb-history'

module Luffa
  module IRBRC
    def self.message_of_the_day
      motd=["Let's get this done!", 'Ready to rumble.', 'Enjoy.', 'Remember to breathe.',
            'Take a deep breath.', "Isn't it time for a break?", 'Can I get you a coffee?',
            'What is a calabash anyway?', 'Smile! You are on camera!', 'Let op! Wild Rooster!',
            "Don't touch that button!", "I'm gonna take this to 11.", 'Console. Engaged.',
            'Your wish is my command.', 'This console session was created just for you.']
      puts "#{motd.shuffle().first}"
    end
  end
end

Luffa::IRBRC.message_of_the_day
