describe Luffa::Xcode do

  let(:dev_dir) { '/Xcode/4.6.3/Xcode.app/Contents/Developer'}

  describe '#with_developer_dir' do
    it 'respects the original value of DEVELOPER_DIR' do
      stub_env('DEVELOPER_DIR', dev_dir)
      begin
        Luffa::Xcode.instance.with_developer_dir('/Some/Other/Dir') do
          raise 'Ack!'
        end
      rescue RuntimeError => _

      end
      expect(ENV['DEVELOPER_DIR']).to be == dev_dir
    end
  end

  it '#xcode_select_path' do
    expect(Luffa::Xcode.instance.xcode_select_path).not_to be == nil
  end

  describe '#active_xcode_dir' do
    let(:xcode) { Luffa::Xcode.instance }

    before(:each) {
      xcode.instance_variable_set(:@active_xcode_dir, nil)
      xcode.instance_variable_set(:@xcode_select_dir, nil)
    }

    after(:each) {
      xcode.instance_variable_set(:@active_xcode_dir, nil)
      xcode.instance_variable_set(:@xcode_select_dir, nil)
    }

    it 'respects the DEVELOPER_DIR' do
      stub_env('DEVELOPER_DIR', dev_dir)
      expect(xcode.active_xcode_dir).to be == dev_dir
    end

    it 'returns the xcode-select --print-path' do
      stub_env({'DEVELOPER_DIR' => nil})
      expect(xcode).to receive(:xcode_select_path).and_return(dev_dir)
      expect(xcode.active_xcode_dir).to be == dev_dir
    end
  end
end
