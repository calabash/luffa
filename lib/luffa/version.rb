module Luffa
  VERSION = "2.0.0"

  # A model of a software release version that can be used to compare two versions.
  #
  # Calabash and RunLoop try very hard to comply with Semantic Versioning rules.
  # However, the semantic versioning spec is incompatible with RubyGem's patterns
  # for pre-release gems.
  #
  # > "But returning to the practical: No release version of SemVer is compatible with Rubygems." - _David Kellum_
  #
  # Calabash and RunLoop version numbers will be in the form `<major>.<minor>.<patch>[.pre<N>]`.
  #
  # @see http://semver.org/
  # @see http://gravitext.com/2012/07/22/versioning.html
  class Version

    # @!attribute [rw] major
    #   @return [Integer] the major version
    attr_accessor :major

    # @!attribute [rw] minor
    #   @return [Integer] the minor version
    attr_accessor :minor

    # @!attribute [rw] patch
    #   @return [Integer] the patch version
    attr_accessor :patch

    # @!attribute [rw] pre
    #   @return [Boolean] true if this is a pre-release version
    attr_accessor :pre

    # @!attribute [rw] pre_version
    #   @return [Integer] if this is a pre-release version, returns the
    #     pre-release version; otherwise this is nil
    attr_accessor :pre_version

    # Creates a new Version instance with all the attributes set.
    #
    # @example
    #  version = Version.new(0.10.1)
    #  version.major       => 0
    #  version.minor       => 10
    #  version.patch       => 1
    #  version.pre         => false
    #  version.pre_release => nil
    #
    # @example
    #  version = Version.new(1.6.3.pre5)
    #  version.major       => 1
    #  version.minor       => 6
    #  version.patch       => 3
    #  version.pre         => true
    #  version.pre_release => 5
    #
    # @param [String] version the version string to parse.
    # @raise [ArgumentError] if version is not in the form 5, 6.1, 7.1.2, 8.2.3.pre1
    def initialize(version)
      tokens = version.strip.split('.')
      count = tokens.count
      if tokens.empty?
        raise ArgumentError, "expected '#{version}' to be like 5, 6.1, 7.1.2, 8.2.3.pre1"
      end

      if count < 4 and tokens.any? { |elm| elm =~ /\D/ }
        raise ArgumentError, "expected '#{version}' to be like 5, 6.1, 7.1.2, 8.2.3.pre1"
      end

      if count == 4
        @pre = tokens[3]
        pre_tokens = @pre.scan(/\D+|\d+/)
        @pre_version = pre_tokens[1].to_i if pre_tokens.count == 2
      end

      @major, @minor, @patch = version.split('.').map(&:to_i)
    end

    # Returns an string representation of this version.
    # @return [String] a string in the form `<major>.<minor>.<patch>[.pre<N>]`
    def to_s
      str = [major, minor, patch].compact.join('.')
      str = "#{str}.#{pre}" if pre
      str
    end

    # Compare this version to another for equality.
    # @param [Version] other the version to compare against
    # @return [Boolean] true if this Version is the same as `other`
    def == (other)
      Version.compare(self, other) == 0
    end

    # Compare this version to another for inequality.
    # @param [Version] other the version to compare against
    # @return [Boolean] true if this Version is not the same as `other`
    def != (other)
      Version.compare(self, other) != 0
    end

    # Is this version less-than another version?
    # @param [Version] other the version to compare against
    # @return [Boolean] true if this Version is less-than `other`
    def < (other)
      Version.compare(self, other) < 0
    end

    # Is this version greater-than another version?
    # @param [Version] other the version to compare against
    # @return [Boolean] true if this Version is greater-than `other`
    def > (other)
      Version.compare(self, other) > 0
    end

    # Is this version less-than or equal to another version?
    # @param [Version] other the version to compare against
    # @return [Boolean] true if this Version is less-than or equal `other`
    def <= (other)
      Version.compare(self, other) <= 0
    end

    # Is this version greater-than or equal to another version?
    # @param [Version] other the version to compare against
    # @return [Boolean] true if this Version is greater-than or equal `other`
    def >= (other)
      Version.compare(self, other) >= 0
    end

    # Compare version `a` to version `b`.
    #
    # @example
    #   compare Version.new(0.10.0), Version.new(0.9.0)  =>  1
    #   compare Version.new(0.9.0),  Version.new(0.10.0) => -1
    #   compare Version.new(0.9.0),  Version.new(0.9.0)  =>  0
    #
    # @return [Integer] an integer `(-1, 1)`
    def self.compare(a, b)

      if a.major != b.major
        return a.major > b.major ? 1 : -1
      end

      if a.minor != b.minor
        return a.minor.to_i  > b.minor.to_i ? 1 : -1
      end

      if a.patch != b.patch
        return a.patch.to_i > b.patch.to_i ? 1 : -1
      end

      return -1 if a.pre and (not a.pre_version) and b.pre_version
      return 1 if a.pre_version and b.pre and (not b.pre_version)

      return -1 if a.pre and (not b.pre)
      return 1 if (not a.pre) and b.pre

      return -1 if a.pre_version and (not b.pre_version)
      return 1 if (not a.pre_version) and b.pre_version

      if a.pre_version != b.pre_version
        return a.pre_version.to_i > b.pre_version.to_i ? 1 : -1
      end
      0
    end
  end
end
