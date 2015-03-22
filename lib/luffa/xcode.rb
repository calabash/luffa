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

    # The developer dir at the time the tests start.
    #
    # To change the active Xcode:
    #
    #   $ DEVELOPER_DIR=/path/to/Xcode.app/Contents/Developer be rake spec
    def active_xcode_dir
      @active_xcode_dir ||= lambda {
        env = Luffa::Environment.developer_dir
        if env
          env
        else
          # fall back to xcode-select
          xcode_select_path
        end
      }.call
    end

    def xcode_select_path
      @xcode_select_dir ||= `xcode-select --print-path`.chomp
    end
  end
end
