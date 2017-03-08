require 'optparse'
require 'yaml'

module InterpolToOpenAPI
  class CLI
    def initialize(argv)
      @src = nil

      define_cli_options(argv)
    end

    def run
      raise 'Give input yaml path with -i option.' if @src.nil?

      converter = InterpolToOpenAPI::Converter.new
      puts converter.convert(@src).to_yaml
    end

    private

    def define_cli_options(argv)
      @opt = OptionParser.new

      @opt.on('-v', '--version', 'print the version') do
        puts InterpolToOpenAPI::VERSION
        exit
      end

      @opt.on('-i path', '--input', 'path to input endpoint definition yaml') do |path|
        @src = path
      end

      @opt.parse!(argv)
    end
  end
end
