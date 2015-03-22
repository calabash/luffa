describe Luffa::Gem do

  let(:options) { {:exit_on_nonzero_status => false} }

  it 'can update rubygems, install gems, and uninstall gems' do
    expect(Luffa::Gem.update_rubygems(options)).to be == 0
    expect(Luffa::Gem.install_gem('apfel', options)).to be == 0
    expect(Luffa::Gem.uninstall_gem('apfel', options)).to be == 0
  end

end
