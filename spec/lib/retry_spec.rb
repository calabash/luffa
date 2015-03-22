describe Luffa::Retry do

  describe '#launch_retries' do
    it 'returns 2 when not TRAVIS' do
      stub_env({'TRAVIS' => nil})
      retries = Luffa::Retry.instance
      retries.instance_variable_set(:@launch_retries, nil)
      expect(retries.launch_retries).to be == 2
    end

    it 'returns 8 when TRAVIS' do
      stub_env({'TRAVIS' => true})
      retries = Luffa::Retry.instance
      retries.instance_variable_set(:@launch_retries, nil)
      expect(retries.launch_retries).to be == 8
    end
  end
end
