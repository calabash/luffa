module Luffa
  class XcodeInstall
    attr :version
    attr :path

    def initialize(path)
      Luffa::Xcode.with_developer_dir(path) do
        @version = lambda {
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
        ENV['DEVELOPER_DIR'] = stripped
        block.call
      ensure
        ENV['DEVELOPER_DIR'] = original_developer_dir
      end
    end

    def self.with_xcode_install(xcode_install, &block)
      self.with_developer_dir(xcode_install.path, &block)
    end

    def xcode_installs
      @xcode_installs ||= lambda do
        min_xcode_version = Luffa::Version.new('5.1.1')
        active_xcode = Luffa::Xcode.new.active_xcode
        xcodes = [active_xcode]
        Dir.glob('/Xcode/*/*.app/Contents/Developer').each do |path|
          xcode_version = path[/(\d\.\d(\.\d)?)/, 0]
          if Luffa::Version.new(xcode_version) >= min_xcode_version
            install = Luffa::XcodeInstall.new(path)
            unless install == active_xcode
              xcodes << install
            end
          end
        end
        xcodes
      end.call
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
