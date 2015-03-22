describe Luffa::Environment do

  describe '.travis_ci?' do
    describe 'returns false' do
      it 'when TRAVIS is nil' do
        stub_env({'TRAVIS' => nil})
        expect(subject.travis_ci?).to be == false
      end

      it 'when TRAVIS is empty' do
        stub_env('TRAVIS', '')
        expect(subject.travis_ci?).to be == false
      end
    end

    it 'returns true' do
      stub_env('TRAVIS', true)
      expect(subject.travis_ci?).to be == true
    end
  end

  describe '.jenkins_ci?' do
    describe 'returns false' do
      it 'when JENKINS_HOME is nil' do
        stub_env({'JENKINS_HOME' => nil})
        expect(subject.jenkins_ci?).to be == false
      end

      it 'when JENKINS_HOME is empty' do
        stub_env('JENKINS_HOME', '')
        expect(subject.jenkins_ci?).to be == false
      end
    end

    it 'returns true' do
      stub_env('JENKINS_HOME', '/Users/jenkins')
      expect(subject.jenkins_ci?).to be == true
    end
  end

  describe '.ci?' do

    describe 'returns true' do
      it 'when on jenkins' do
        stub_env('JENKINS_HOME', '/Users/jenkins')
        expect(subject.ci?).to be == true
      end

      it 'when on travis' do
        stub_env('TRAVIS', true)
        expect(subject.ci?).to be == true
      end
    end

    it 'returns false' do
      allow(subject).to receive(:travis_ci?).and_return false
      allow(subject).to receive(:jenkins_ci?).and_return false
      expect(subject.ci?).to be == false
    end
  end

  describe '.developer_dir' do
    describe 'returns nil' do
      it 'when DEVELOPER_DIR is nil' do
        stub_env({'DEVELOPER_DIR' => nil})
        expect(subject.developer_dir).to be == nil
      end

      it 'when DEVELOPER_DIR is empty' do
        stub_env('DEVELOPER_DIR', '')
        expect(subject.developer_dir).to be == nil
      end
    end

    it 'returns DEVELOPER_DIR' do
      stub_env('DEVELOPER_DIR', '/Some/path')
      expect(subject.developer_dir).to be == '/Some/path'
    end
  end
end
