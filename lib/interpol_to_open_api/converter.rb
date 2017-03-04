require 'yaml'

class String
  def camelize
    self.split("_").map {|w|
      w[0] = w[0].upcase
      w
    }.join
  end
end

module InterpolToOpenAPI
  class Converter
    def convert(path)
      interpol = YAML.load_file(path)

      req, res = interpol['definitions'].partition {|definition| definition['message_type'] == 'request' }

      parameters = []
      parameters += parameters_in_path(req.first['path_params']['properties'])
      parameters += parameters_in_query(req.first['query_params']['properties'])
      parameters += parameters_in_body(req.first['schema'])

      status_code = res.first['status_codes'].first
      responses = {}
      responses[status_code] = {
        'description' => '',
        'schema' => res.first['schema'].merge({
          'example' => res.first['examples'].first
        })
      }

      {
        interpol['route'] => {
          interpol['method'].downcase => {
            'summary' => '',
            'description' => req.first['schema']['description'] || '',
            'parameters' => parameters,
            'responses' => responses
          }
        }
      }
    end

    private

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
      return [] unless schema.is_a? Hash

      schema['properties'].map do |name, schema|
        {
          'in' => 'body',
          'name' => name,
          'description' => '',
          'schema' => schema
        }
      end
    end
  end
end
