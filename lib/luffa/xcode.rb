module Luffa
  class XcodeInstall
    attr :version
    attr :path

    def initialize(path)
      Luffa::Xcode.with_developer_dir(path) do
        @version = lambda {
          puts "path = #{path}"
          xcode_build_output = `xcrun xcodebuild -version`.split(/\s/)[1]
          Luffa::Version.new(xcode_build_output)
        }.call

        @path = path
      end
    end

    def version_string
      version.to_s
    end

    def == (other)
      other.path == path && other.version == version
    end
  end

  class Xcode
    def self.with_developer_dir(developer_dir, &block)
      original_developer_dir = Luffa::Environment.developer_dir
      stripped = developer_dir.strip
      begin
        ENV.delete('DEVELOPER_DIR')
        ENV['DEVELOPER_DIR'] = stripped
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
      @xcode_select_dir ||= `xcode-select --print-path`.strip
    end

    def active_xcode
      @active_xcode ||= Luffa::XcodeInstall.new(active_xcode_dir)
    end
  end
end
