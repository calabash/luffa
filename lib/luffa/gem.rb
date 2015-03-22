module Luffa
  class Gem

    def self.update_rubygems(unix_command_opts={})
      default_opts = {:pass_msg => 'Updated rubygems',
                      :fail_msg => 'Could not update rubygems'}

      Luffa.unix_command('gem update --system',
                         default_opts.merge(unix_command_opts))
    end

    def self.uninstall_gem(gem_name, unix_command_opts={})
      default_opts = {:pass_msg => "Uninstalled '#{gem_name}'",
                      :fail_msg => "Could not uninstall '#{gem_name}'"}
      Luffa.unix_command("gem uninstall -Vax --force --no-abort-on-dependent #{gem_name}",
                         default_opts.merge(unix_command_opts))
    end

    def self.install_gem(gem_name, opts={})
      default_opts = {:prerelease => false,
                      :no_document => true,
                      :pass_msg => "Installed '#{gem_name}'",
                      :fail_msg => "Could not install '#{gem_name}'"}

      merged_opts = default_opts.merge(opts)

      pre = merged_opts[:prerelease] ? '--pre' : ''
      no_document = merged_opts[:no_document] ? '--no-document' : ''

      Luffa.unix_command("gem install #{no_document} #{gem_name} #{pre}",
                         merged_opts)
    end

  end
end
