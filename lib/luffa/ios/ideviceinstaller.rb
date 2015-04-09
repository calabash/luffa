require 'retriable'

module Luffa
  class IDeviceInstaller

    attr_reader :ipa
    attr_reader :bundle_id

    def initialize(ipa, bundle_id)
      @ipa = ipa
      @bundle_id = bundle_id
    end

    def bin_path
      @bin_path ||= `which ideviceinstaller`.chomp!
    end

    def ideviceinstaller_available?
      path = bin_path
      path and File.exist? bin_path
    end

    def install(udid, cmd)
      case cmd
        when :install_internal
          ipa
          Retriable.retriable do
            uninstall udid
          end
          Retriable.retriable do
            install_internal udid
          end
        when :uninstall
          Retriable.retriable do
            uninstall udid
          end
        else
          cmds = [:install_internal, :uninstall]
          raise ArgumentError, "expected '#{cmd}' to be one of '#{cmds}'"
      end
    end

    def bundle_installed?(udid)
      cmd = "#{bin_path} --udid #{udid} --list-apps"
      Luffa.log_unix_cmd(cmd) if Luffa::Environment.debug?

      Open3.popen3(cmd) do  |_, stdout,  stderr, _|
        err = stderr.read.strip
        Luffa.log_fail(err) if err && err != ''

        out = stdout.read.strip
        out.strip.split(/\s/).include? bundle_id
      end
    end

    def install_internal(udid)
      return true if bundle_installed? udid

      cmd = "#{bin_path} --udid #{udid} --install #{ipa}"
      Luffa.log_unix_cmd(cmd) if Luffa::Environment.debug?

      Open3.popen3(cmd) do  |_, _,  stderr, _|
        err = stderr.read.strip
        Luffa.log_fail(err) if err && err != ''
      end

      unless bundle_installed? udid
        raise "could not install '#{ipa}' on '#{udid}' with '#{bundle_id}'"
      end
      true
    end

    def uninstall(udid)
      return true unless bundle_installed? udid

      cmd = "#{bin_path} -udid #{udid} --uninstall #{bundle_id}"
      Luffa.log_unix_cmd(cmd) if Luffa::Environment.debug?

      Open3.popen3(cmd) do  |_, _,  stderr, _|
        err = stderr.read.strip
        Luffa.log_fail(err) if err && err != ''
      end

      if bundle_installed? udid
        raise "could not uninstall '#{bundle_id}' on '#{udid}'"
      end
      true
    end

    def idevice_id_bin_path
      @idevice_id_bin_path ||= `which idevice_id`.chomp!
    end

    def idevice_id_available?
      path = idevice_id_bin_path
      path and File.exist? path
    end

    def physical_devices_for_testing(xcode_tools)
      # Xcode 6 + iOS 8 - devices on the same network, whether development or
      # not, appear when calling $ xcrun instruments -s devices. For the
      # purposes of testing, we will only try to connect to devices that are
      # connected via USB.
      #
      # Also idevice_id, which ideviceinstaller relies on, will sometimes report
      # devices 2x which will cause ideviceinstaller to fail.
      @physical_devices_for_testing ||= lambda {
        devices = xcode_tools.instruments(:devices)
        if idevice_id_available?
          white_list = `#{idevice_id_bin_path} -l`.strip.split("\n")
          devices.select do | device |
            white_list.include?(device.udid) && white_list.count(device.udid) == 1
          end
        else
          devices
        end
      }.call
    end

  end
end
