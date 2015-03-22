require 'luffa/cli/cli'

describe Luffa::CLI do
  context 'version' do
    subject { capture_stdout { Luffa::CLI.new.version }.string.strip }
    it { is_expected.to be == Luffa::VERSION }
  end

  context 'authorize' do
    it 'when not travis ci' do
      expect(Luffa::Environment).to receive(:travis_ci?).and_return false
      val = nil
      out = capture_stdout {
        val = Luffa::CLI.new.authorize
      }.string
      expect(val).to be == true
      expect(out[/Skipping/,0]).not_to be == nil
    end

    describe 'when travis ci' do
      it 'will fail if analysis.plist write fails' do
        expect(Luffa::Environment).to receive(:travis_ci?).and_return true
        expect(Luffa).to receive(:unix_command).exactly(2).times.and_return(1, 0)
        expect(Luffa::CLI.new.authorize).to be == false
      end

      it 'will fail if kill.plist write fails' do
        expect(Luffa::Environment).to receive(:travis_ci?).and_return true
        expect(Luffa).to receive(:unix_command).exactly(2).times.and_return(0, 1)
        expect(Luffa::CLI.new.authorize).to be == false
      end

      it 'will pass if both plist writes pass' do
        expect(Luffa::Environment).to receive(:travis_ci?).and_return true
        expect(Luffa).to receive(:unix_command).exactly(2).times.and_return(0, 0)
        expect(Luffa::CLI.new.authorize).to be == true
      end
    end
  end
end
