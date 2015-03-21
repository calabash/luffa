module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out
  ensure
    $stdout = STDOUT
  end

  def capture_stderr
    out = StringIO.new
    $stderr = out
    yield
    return out
  ensure
    $stderr = STDERR
  end
end
