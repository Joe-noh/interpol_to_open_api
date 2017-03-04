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

      parameters = (req.first['path_params']['properties'] || []).map {|(name, schema)|
        {
          'in' => 'path',
          'name' => name.camelize,
          'description' => '',
          'required' => true,
          'type' => schema['type']
        }
      }
      parameters << (req.first['query_params'] || []).map {|name, schema|
        {
          'in' => 'query',
          'name' => name.camelize,
          'description' => '',
          'type' => schema['type']
        }
      }
      parameters << (req.first['schema']['properties'] || []).map {|name, schema|
        {
          'in' => 'body',
          'name' => name.camelize,
          'description' => '',
          'schema' => schema
        }
      }

      status_code = res.first['status_codes'].first
      responses = {}
      responses[status_code] = {
        'description' => '',
        'schema' => res.first['schema']
      }

      {
        interpol['route'] => {
          interpol['method'].downcase => {
            'responses' => responses,
            'parameters' => parameters
          }
        }
      }
    end
  end
end
