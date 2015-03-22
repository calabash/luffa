module Luffa
  def self.unix_command(cmd, opts={})
    default_opts = {:pass_msg => nil,
                    :fail_msg => nil,
                    :exit_on_nonzero_status => true,
                    :env_vars => {},
                    :log_cmd => true,
                    :obscure_fields => []}
    merged_opts = default_opts.merge(opts)

    obscure_fields = merged_opts[:obscure_fields]

    if not obscure_fields.empty? and merged_opts[:log_cmd]
      obscured = cmd.split(' ').map do |token|
        if obscure_fields.include? token
          "#{token[0,1]}***#{token[token.length-1,1]}"
        else
          token
        end
      end
      Luffa.log_unix_cmd obscured.join(' ')
    elsif merged_opts[:log_cmd]
      Luffa.log_unix_cmd cmd
    end

    exit_on_err = merged_opts[:exit_on_nonzero_status]
    unless exit_on_err
      system 'set +e'
    end

    env_vars = merged_opts[:env_vars]
    res = system(env_vars, cmd)
    exit_code = $?.exitstatus

    if res
      Luffa.log_pass merged_opts[:pass_msg]
    else
      Luffa.log_fail merged_opts[:fail_msg]
      exit exit_code if exit_on_err
    end
    system 'set -e'
    exit_code
  end
end
