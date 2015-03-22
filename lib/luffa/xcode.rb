require 'singleton'

module Luffa
  class Xcode
    include Singleton
    def with_developer_dir(developer_dir, &block)
      original_developer_dir = Luffa::Environment.developer_dir
      begin
        ENV.delete('DEVELOPER_DIR')
        ENV['DEVELOPER_DIR'] = developer_dir
        block.call
      ensure
        ENV['DEVELOPER_DIR'] = original_developer_dir
      end
    end
  end
end
