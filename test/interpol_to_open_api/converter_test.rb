require 'test_helper'

class InterpolToOpenAPI::ConverterTest < Minitest::Test
  def test_conversion
    converter = InterpolToOpenAPI::Converter.new(src: File.expand_path('../../fixtures/sample.interpol.yaml', __FILE__))
    expected = YAML.load_file(File.expand_path('../../fixtures/sample.openapi.yaml', __FILE__))

    assert_equal converter.convert, expected
  end
end
