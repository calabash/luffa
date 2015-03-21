module Luffa
  def self.log_unix_cmd(msg)
    puts "\033[36mEXEC: #{msg}\033[0m" if msg
  end

  def self.log_pass(msg)
    puts "\033[32mPASS: #{msg}\033[0m" if msg
  end

  def self.log_warn(msg)
    puts "\033[34mWARN: #{msg}\033[0m"
  end

  def self.log_fail(msg)
    puts "\033[31mFAIL: #{msg}\033[0m" if msg
  end

  def self.log_info(msg)
    puts "\033[46mINFO: #{msg}\033[0m" if msg
  end
end
