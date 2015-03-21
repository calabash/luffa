describe Luffa do
  it 'log_unix_cmd' do
    capture_stdout { Luffa.log_unix_cmd 'Hey!' }
  end

  it 'log_pass' do
    capture_stdout { Luffa.log_pass 'Hey!' }
  end

  it 'log_fail' do
    capture_stdout { Luffa.log_fail 'Hey!' }
  end

  it 'log_warn' do
    capture_stdout { Luffa.log_warn 'Hey!' }
  end

  it 'log_info' do
    capture_stdout { Luffa.log_info 'Hey!' }
  end
end
