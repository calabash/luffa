module Luffa
  module Environment
    def self.travis_ci?
      value = ENV['TRAVIS']
      !value.nil? && value != ''
    end

    def self.jenkins_ci?
      value = ENV['JENKINS_HOME']
      !value.nil? && value != ''
    end

    def self.ci?
      self.travis_ci? || self.jenkins_ci?
    end
  end
end
