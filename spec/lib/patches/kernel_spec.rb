describe 'capture IO' do
  it 'capture_stdout' do
    out = capture_stdout do
      puts 'Hey!'
    end
    expect(out.string).to be == "Hey!\n"
  end

  it 'capture_stderr' do
    out = capture_stderr do
      warn 'Hey!'
    end
    expect(out.string).to be == "Hey!\n"
  end
end
