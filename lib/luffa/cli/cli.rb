require 'thor'
require 'luffa/cli/cli'

trap 'SIGINT' do
  puts 'Exiting'
  exit 10
end

module Luffa

  class ValidationError < Thor::InvocationError
  end

  class CLI < Thor
    include Thor::Actions

    def self.exit_on_failure?
      true
    end

    desc 'version', 'Prints version of the luffa gem'
    def version
      puts Luffa::VERSION
    end
  end
end


