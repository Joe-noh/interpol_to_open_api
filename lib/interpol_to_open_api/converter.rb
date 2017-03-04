require 'yaml'

class String
  def camelize
    self.gsub(/_([a-z])/) { $1.upcase }
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

      route = camelize_path_parameters(interpol['route'])

      {
        route => {
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

    def camelize_path_parameters(path)
      path.gsub(/:([\w]+)/) do |_matched|
        "{" + $1.camelize + "}"
      end
    end
  end
end
