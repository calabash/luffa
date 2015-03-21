describe 'monkey patching' do
  it "awesome-print '=='" do
    Open3.popen3('sh') do |stdin, stdout, stderr, _|
      stdin.puts 'bundle exec irb <<EOF'
      stdin.puts "require 'luffa'"
      stdin.puts 'module Foo'
      stdin.puts '  class SomeClass'
      stdin.puts '    def == (other)'
      stdin.puts '      SomeClass.compare(self, other) == 0'
      stdin.puts '    end'
      stdin.puts '    def self.compare(_)'
      stdin.puts '      [1,0].sample'
      stdin.puts '    end'
      stdin.puts '  end'
      stdin.puts 'end'
      stdin.puts 'foo = Foo::SomeClass.new'
      stdin.puts 'EOF'
      stdin.close
      out = stdout.read.strip
      err = stderr.read.strip
      expect(out[/Error:/,0]).to be == nil
      expect(err).to be == ''
    end
  end
end
