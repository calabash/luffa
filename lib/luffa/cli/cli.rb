require 'thor'
require 'luffa/cli/cli'
require 'luffa/environment'
require 'luffa/unix_command'

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

    desc 'authorize', 'Runs instruments authorization scripts - will only run on travis-ci'
    def authorize
      this_dir = File.dirname(__FILE__)
      relative_path = File.join(this_dir, '..', '..', '..', 'script', 'ci')
      plist_path = File.expand_path(relative_path)

      analysis_plist = "#{plist_path}/com.apple.dt.instruments.process.analysis.plist"
      kill_plist = "#{plist_path}/com.apple.dt.instruments.process.kill.plist"

      analysis_domain = 'com.apple.dt.instruments.process.analysis'
      analysis_args = ['security', 'authorizationdb', 'write', analysis_domain]

      kill_domain = 'com.apple.dt.instruments.process.kill'
      kill_args = ['security', 'authorizationdb', 'write', kill_domain]

      if Luffa::Environment.travis_ci?
        cmd = "sudo #{analysis_args.join(' ')} < \"#{analysis_plist}\""
        options = {
              :pass_msg => 'Wrote analysis.plist',
              :fail_msg => 'Could not write analysis.plist',
              :exit_on_nonzero_status => false
        }
        analysis_code = Luffa.unix_command(cmd, options)

        cmd = "sudo #{kill_args.join(' ')} < \"#{kill_plist}\""
        options = {
              :pass_msg => 'Wrote kill.plist',
              :fail_msg => 'Could not write kill.plist',
              :exit_on_nonzero_status => false
        }

        kill_code = Luffa.unix_command(cmd, options)
        analysis_code == 0 && kill_code == 0
      else
        puts "Skipping 'security authorizationdb write' because it requires sudo"
        true
      end
    end
  end
end
