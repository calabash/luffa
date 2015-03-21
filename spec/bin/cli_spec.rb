require 'luffa/cli/cli'

describe Luffa::CLI do
  context 'version' do
    subject { capture_stdout { Luffa::CLI.new.version }.string.strip }
    it { is_expected.to be == Luffa::VERSION }
  end
end
