require 'retriable'
require 'open3'

module Luffa
  class IDeviceInstaller

    attr_reader :ipa
    attr_reader :bundle_id

    def initialize(ipa, bundle_id)
      @ipa = ipa
      @bundle_id = bundle_id
    end

    def self.ideviceinstaller_available?
      path = bin_path
      path and File.exist? bin_path
    end

    def self.idevice_id_available?
      path = idevice_id_bin_path
      path and File.exist? path
    end

    def install(udid, options={})
      if options.is_a? Hash
        merged_options = DEFAULT_OPTIONS.merge(options)
      else
        Luffa.log_warn 'API CHANGE: install now takes an options hash as 2nd arg'
        Luffa.log_warn "API CHANGE: ignoring '#{options}'; will use defaults"
        merged_options = DEFAULT_OPTIONS
      end

      uninstall(udid, merged_options)
      install_internal(udid, merged_options)
    end

    # Can only be called when RunLoop is available.
    def self.physical_devices_for_testing(xcode_tools)
      # Xcode 6 + iOS 8 - devices on the same network, whether development or
      # not, appear when calling $ xcrun instruments -s devices. For the
      # purposes of testing, we will only try to connect to devices that are
      # connected via USB.
      #
      # Also idevice_id, which ideviceinstaller relies on, will sometimes report
      # devices 2x which will cause ideviceinstaller to fail.
      @physical_devices_for_testing ||= lambda {
        devices = xcode_tools.instruments(:devices)
        if self.idevice_id_available?
          white_list = `#{idevice_id_bin_path} -l`.strip.split("\n")
          devices.select do | device |
            white_list.include?(device.udid) && white_list.count(device.udid) == 1
          end
        else
          devices
        end
      }.call
    end

    private

    DEFAULT_OPTIONS =  { :timeout => 10.0, :tries => 2 }

    def bin_path
      @bin_path ||= `which ideviceinstaller`.chomp!
    end

    def run_command_with_args(args, options={})
      merged_options = DEFAULT_OPTIONS.merge(options)

      cmd = "#{bin_path} #{args.join(' ')}"
      Luffa.log_unix_cmd(cmd) if Luffa::Environment.debug?

      exit_status = nil
      out = nil
      pid = nil
      err = nil

      tries = merged_options[:tries]
      timeout = merged_options[:timeout]

      on = [Timeout::Error, RuntimeError]
      on_retry = Proc.new do |_, try, elapsed_time, next_interval|
        # Retriable 2.0
        if elapsed_time && next_interval
          Luffa.log_info "LLDB: attempt #{try} failed in '#{elapsed_time}'; will retry in '#{next_interval}'"
        else
          Luffa.log_info "LLDB: attempt #{try} failed; will retry"
        end
      end

      Retriable.retriable({tries: tries, on: on, on_retry: on_retry} ) do
        Timeout.timeout(timeout, TimeoutError) do
          Open3.popen3(bin_path, *args) do  |_, stdout,  stderr, process_status|
            err = stderr.read.strip
            if err && err != ''
              unless err[/iTunesMetadata.plist/,0] || err[/SC_Info/,0]
                Luffa.log_fail(err)
              end
            end
            out = stdout.read.strip
            pid = process_status.pid
            exit_status = process_status.value.exitstatus
          end
        end

        if exit_status != 0
          raise RuntimeError, "Could not execute #{args.join(' ')}"
        end
      end
      {
            :out => out,
            :err => err,
            :pid => pid,
            :exit_status => exit_status
      }
    end

    def bundle_installed?(udid, options={})
      merged_options = DEFAULT_OPTIONS.merge(options)

      args = ['--udid', udid, '--list-apps']

      hash = run_command_with_args(args, merged_options)
      out = hash[:out]
      out.split(/\s/).include? bundle_id
    end

    def install_internal(udid, options={})
      merged_options = DEFAULT_OPTIONS.merge(options)

      return true if bundle_installed?(udid, merged_options)
      args = ['--udid', udid, '--install', ipa]
      run_command_with_args(args, merged_options)

      unless bundle_installed?(udid, merged_options)
        raise "could not install '#{ipa}' on '#{udid}' with '#{bundle_id}'"
      end
      true
    end

    def uninstall(udid, options={})
      merged_options = DEFAULT_OPTIONS.merge(options)

      return true unless bundle_installed?(udid, merged_options)
      args = ['--udid', udid, '--uninstall', bundle_id]
      run_command_with_args(args)

      if bundle_installed?(udid, merged_options)
        raise "Could not uninstall '#{bundle_id}' on '#{udid}'"
      end
      true
    end

    def idevice_id_bin_path
      @idevice_id_bin_path ||= `which idevice_id`.chomp!
    end
  end
end
