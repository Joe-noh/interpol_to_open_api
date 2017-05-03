require 'yaml'
require_relative 'converter/schema_converter'

module InterpolToOpenAPI
  class Converter
    def initialize
      @schema_converter = SchemaConverter.new
    end

    def convert(path)
      interpol = YAML.load_file(path)

      req, res = interpol['definitions'].partition {|definition| definition['message_type'] == 'request' }

      {
        camelize_path_parameters(interpol['route']) => {
          interpol['method'].downcase => {
            'summary' => '',
            'description' => req.first['schema']['description'] || '',
            'operationId' => interpol['name'].camelize,
            'parameters' => build_parameters(req.first),
            'responses' => build_responses(res.first)
          }
        }
      }
    end

    private

    def build_parameters(request)
      [
        parameters_in_path(request['path_params']['properties']),
        parameters_in_query(request['query_params']['properties']),
        parameters_in_body(request['schema'])
      ].flatten
    end

    def build_responses(response)
      status_code = response['status_codes'].first
      schema = response['schema'].merge({
        'example' => response['examples'].first
      })

      {
        status_code => {
          'description' => '',
          'schema' => @schema_converter.convert(schema)
        }
      }
    end

    def parameters_in_path(properties)
      return [] unless properties.is_a? Hash

      properties.map do |name, schema|
        {
          'in' => 'path',
          'name' => name.camelize,
          'description' => '',
          'required' => true,
          'type' => schema['type']
        }
      end
    end

    def parameters_in_query(properties)
      return [] unless properties.is_a? Hash

      properties.map do |name, schema|
        {
          'in' => 'query',
          'name' => name,
          'description' => '',
          'type' => schema['type']
        }
      end
    end

    def parameters_in_body(schema)
      return [] unless schema['properties'].is_a? Hash

      schema['properties'].map do |name, schema|
        {
          'in' => 'body',
          'name' => name,
          'description' => '',
          'schema' => @schema_converter.convert(schema)
        }
      end
    end

    def camelize_path_parameters(path)
      path.gsub(/:([\w]+)/) do |_matched|
        "{" + $1.camelize + "}"
      end
    end
  end
end
