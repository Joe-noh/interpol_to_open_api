module InterpolToOpenAPI
  class CLI
    def initialize
      p ARGV
    end

    def run
      converter = InterpolToOpenAPI::Converter.new
      p converter
    end
  end
end
