
module Jenkins

  # Launch processes on build slaves. No functionality is currently exposed
  class Launcher

    # the nantive hudson.Launcher object
    attr_reader :native

    def initialize(native = nil)
      @native = native
    end
  end
end