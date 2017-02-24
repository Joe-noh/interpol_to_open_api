module InterpolToOpenAPI
  class CLI
    def initialize
      p ARGV
    end

    def run
      converter = InterpolToOpenAPI.new
      p converter
    end
  end
end
