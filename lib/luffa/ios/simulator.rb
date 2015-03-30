require 'singleton'

module Luffa
  class Simulator

    include Singleton

    def core_simulator_home_dir
      @core_simulator_home_dir ||= File.expand_path('~/Library/Developer/CoreSimulator')
    end

    def core_simulator_device_dir(sim_udid=nil)
      if sim_udid.nil?
        @core_simulator_device_dir ||= File.expand_path(File.join(core_simulator_home_dir, 'Devices'))
      else
        File.expand_path(File.join(core_simulator_device_dir, sim_udid))
      end
    end

    def core_simulator_device_containers_dir(sim_udid)
      File.expand_path(File.join(core_simulator_device_dir(sim_udid), 'Containers'))
    end

    def core_simulator_for_xcode_version(idiom, form_factor, xcode_version)
      if xcode_version < Luffa::Version.new('6.1')
        ios_version = '8.0'
      elsif xcode_version < Luffa::Version.new('6.2')
        ios_version = '8.1'
      elsif xcode_version < Luffa::Version.new('6.3')
        ios_version = '8.2'
      elsif xcode_version >= Luffa::Version.new('6.3')
        ios_version = '8.3'
      else
        raise "Unsupported Xcode version: #{xcode_version}"
      end
      "#{idiom} #{form_factor} (#{ios_version} Simulator)"
    end
  end
end
