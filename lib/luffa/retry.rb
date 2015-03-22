require 'singleton'

module Luffa
  class Retry
    include Singleton

    def launch_retries
      @launch_retries ||= lambda {
        Luffa::Environment.travis_ci? ? 8 : 2
      }.call
    end
  end
end
