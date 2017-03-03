require 'optparse'

module InterpolToOpenAPI
  class CLI
    def initialize(argv)
      @glob = nil
      @output = nil

      define_cli_options(argv)
    end

    def run
      converter = InterpolToOpenAPI::Converter.new(
        src: @glob,
        dest: @output
      )

      converter.convert
    end

    private

    def define_cli_options(argv)
      @opt = OptionParser.new

      @opt.on('-v', '--version', 'print the version') do
        puts InterpolToOpenAPI::VERSION
        exit
      end

      @opt.on('-i path', '--input', 'path to input endpoint definition yaml') do |path|
        @glob = path
      end

      @opt.on('-o path', '--output', 'path to output open api yaml') do |path|
        @output = path
      end

      @opt.parse!(argv)
    end
  end
end
