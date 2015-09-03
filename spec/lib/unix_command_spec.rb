describe 'Luffa.unix_command' do

  it 'executes unix commands' do
    actual = nil
    capture_stdout {
      actual = Luffa.unix_command 'echo $USER > /dev/null'
    }
    expect(actual).to be == 0
  end

  it 'optionally does not exit on command failure' do
    actual = nil
    capture_stdout {
      actual = Luffa.unix_command('some-command-that-does-not-exist 2> /dev/null',
                                  {:exit_on_nonzero_status => false})
    }
    expect(actual).not_to be == 0
  end

  it 'can obscure command arguments' do
    secret = 'abcdefg'
    actual = nil
    out = capture_stdout {
      actual = Luffa.unix_command("echo #{secret} > /dev/null",
                                  {:obscure_fields => [secret]})
    }.string

    expect(actual).to be == 0
    expect(out[/a\*\*\*g/,0]).not_to be == nil
  end

  it 'can set ENV vars' do
    path = "#{Dir.mktmpdir}/out.txt"

    exit_code = Luffa.unix_command("echo $FOOBAR > #{path}",
                                   {:env_vars => {'FOOBAR' => 'foobar'}})
    expect(exit_code).to be == 0
    actual = File.open(path, 'rb').read.strip
    expect(actual).to be == 'foobar'
  end

  describe 'splitting command' do
    describe 'raises error' do
      let(:options) { {:split_cmd => true} }

      it 'contains |' do
        cmd = 'command with | to another'
        expect do
          Luffa.unix_command(cmd, options)
        end.to raise_error RuntimeError, /Cannot split command/
      end

      it 'contains >' do
        cmd = 'command with > to output'
        expect do
          Luffa.unix_command(cmd, options)
        end.to raise_error RuntimeError, /Cannot split command/
      end

      it 'contains &' do
        cmd = 'command with & to output'
        expect do
          Luffa.unix_command(cmd, options)
        end.to raise_error RuntimeError, /Cannot split command/
      end
    end
  end
end

