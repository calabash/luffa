module Luffa
  module Debug
    def self.with_debugging(&block)
      original_value = ENV['DEBUG']
      ENV['DEBUG'] = '1'
      begin
        block.call
      ensure
        ENV['DEBUG'] = original_value
      end
    end
  end
end
