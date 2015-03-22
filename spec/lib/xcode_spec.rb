describe Luffa::Xcode do

  describe '#with_developer_dir' do
    it 'respects the original value of DEVELOPER_DIR' do
      dev_dir = '/Xcode/4.6.3/Xcode.app/Contents/Developer'
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
end
