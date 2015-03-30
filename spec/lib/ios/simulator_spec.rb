describe Luffa::Simulator do

  it 'is a singleton' do
    expect(Luffa::Simulator.instance).to be_a_kind_of Luffa::Simulator
  end
end
