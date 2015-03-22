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

  it '.with_xcode_install' do
    installs = xcode.xcode_installs
    installs.each do |install|
      Luffa::Xcode.with_xcode_install(install) do
        install_version = install.version
        active_version = Luffa::Xcode.new.active_xcode.version
        expect(install_version).to be == active_version
      end
    end
  end

  it '.ios_version_incompatible_with_xcode_version? can use RunLoop::Version' do
    a = LikeRunLoop::Version.new('8.0')
    b = LikeRunLoop::Version.new('8.0')
    expect { Luffa::Xcode.ios_version_incompatible_with_xcode_version?(a, b) }.not_to raise_error
    expect { Luffa::Xcode.ios_version_incompatible_with_xcode_version?(b, a) }.not_to raise_error
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

  it '#xcode_installs' do
    installs = xcode.xcode_installs
    expect(installs).to be_a_kind_of(Array)
    expect(installs.count).to be >= 1
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

module LikeRunLoop
  class Version
    attr_accessor :major
    attr_accessor :minor
    attr_accessor :patch
    attr_accessor :pre
    attr_accessor :pre_version
    def initialize(version)
      tokens = version.strip.split('.')
      count = tokens.count
      if tokens.empty?
        raise ArgumentError, "expected '#{version}' to be like 5, 6.1, 7.1.2, 8.2.3.pre1"
      end

      if count < 4 and tokens.any? { |elm| elm =~ /\D/ }
        raise ArgumentError, "expected '#{version}' to be like 5, 6.1, 7.1.2, 8.2.3.pre1"
      end

      if count == 4
        @pre = tokens[3]
        pre_tokens = @pre.scan(/\D+|\d+/)
        @pre_version = pre_tokens[1].to_i if pre_tokens.count == 2
      end

      @major, @minor, @patch = version.split('.').map(&:to_i)
    end

    def to_s
      str = [major, minor, patch].compact.join('.')
      str = "#{str}.#{pre}" if pre
      str
    end

    def == (other)
      Version.compare(self, other) == 0
    end

    def != (other)
      Version.compare(self, other) != 0
    end

    def < (other)
      Version.compare(self, other) < 0
    end

    def > (other)
      Version.compare(self, other) > 0
    end

    def <= (other)
      Version.compare(self, other) <= 0
    end

    def >= (other)
      Version.compare(self, other) >= 0
    end

    def self.compare(a, b)

      if a.major != b.major
        return a.major > b.major ? 1 : -1
      end

      if a.minor != b.minor
        return a.minor.to_i  > b.minor.to_i ? 1 : -1
      end

      if a.patch != b.patch
        return a.patch.to_i > b.patch.to_i ? 1 : -1
      end

      return -1 if a.pre and (not a.pre_version) and b.pre_version
      return 1 if a.pre_version and b.pre and (not b.pre_version)

      return -1 if a.pre and (not b.pre)
      return 1 if (not a.pre) and b.pre

      return -1 if a.pre_version and (not b.pre_version)
      return 1 if (not a.pre_version) and b.pre_version

      if a.pre_version != b.pre_version
        return a.pre_version.to_i > b.pre_version.to_i ? 1 : -1
      end
      0
    end
  end
end
