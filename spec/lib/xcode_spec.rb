describe Luffa::Xcode do

  let(:xcode) { Luffa::Xcode.new }
  let(:dev_dir) { '/Xcode/4.6.3/Xcode.app/Contents/Developer'}

  describe '.with_developer_dir' do
    it 'respects the original value of DEVELOPER_DIR' do
      # Can't fake this path because .with_developer_dir sets DEVELOPER_DIR
      xcode_select_dir = `xcode-select --print-path`.strip
      stub_env('DEVELOPER_DIR', xcode_select_dir)
      begin
        Luffa::Xcode.with_developer_dir('/Some/Other/Dir') do
          raise 'Ack!'
        end
      rescue RuntimeError => _

      end
      expect(ENV['DEVELOPER_DIR']).to be == xcode_select_dir
    end
  end

  it '#xcode_select_path' do
    expect(xcode.xcode_select_path).not_to be == nil
  end

  describe '#active_xcode_dir' do
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

  it '#active_xcode' do
    expect(xcode.active_xcode).to be_a_kind_of(Luffa::XcodeInstall)
  end
end

describe Luffa::XcodeInstall do
  let(:xcode) { Luffa::Xcode.new }

  it '.new' do
    path = xcode.xcode_select_path
    install = Luffa::XcodeInstall.new(path)
    expect(install.path).to be == path
    expect(install.version).to be_a_kind_of(Luffa::Version)
  end

  it 'can create a Luffa::Version from #version_string' do
    # We will be passing these strings to RunLoop::Version.new
    install = Luffa::XcodeInstall.new(xcode.xcode_select_path)
    version_string = install.version_string
    version = Luffa::Version.new(version_string)
    expect(version == install.version).to be == true
  end

  it '==' do
    a = Luffa::XcodeInstall.new(xcode.xcode_select_path)
    b = Luffa::XcodeInstall.new(xcode.xcode_select_path)
    expect(a).to be == b
  end
end
