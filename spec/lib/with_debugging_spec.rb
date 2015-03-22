describe Luffa::Debug do
  describe '.with_debugging' do
    it 'respects the original value of DEBUG' do
      stub_env('DEBUG', '10')
      begin
        Luffa::Debug.with_debugging do
          raise 'Ack!'
        end
      rescue RuntimeError => _

      end
      expect(ENV['DEBUG']).to be == '10'
    end
  end
end
