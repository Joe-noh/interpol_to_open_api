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
    def initialize(opts)
      @files = Dir.glob(opts[:src])
      @dest = opts[:dest]
    end

    def convert
      interpols = @files.map {|file| YAML.load_file(file) }
      p (
        interpols.group_by {|interpol| interpol['method'].downcase }.inject({}) do |acc, (method, routes)|
          acc[method] = routes.map do |route|
            req, res = route['definitions'].partition {|definition| definition['message_type'] == 'request' }

            parameters = (req.first['path_params']['properties'] || []).map {|(name, schema)|
              {
                in: 'path',
                name: name.camelize,
                description: '',
                required: true,
                type: schema['type']
              }
            }
            parameters << (req.first['query_params'] || []).map {|name, schema|
              {
                in: 'query',
                name: name.camelize,
                description: '',
                type: schema['type']
              }
            }
            parameters << (req.first['schema']['properties'] || []).map {|name, schema|
              {
                in: 'body',
                name: name.camelize,
                description: '',
                schema: schema
              }
            }

            status_code = res.first['status_codes'].first
            responses = {}
            responses[status_code] = {
              description: '',
              schema: res.first['schema']
            }

            {
              responses: responses,
              parameters: parameters
            }
          end

          acc
        end
      )
    end
  end
end
