module InterpolToOpenAPI
  module Interpol
    class Property
      def self.array_to_openapi(properties)
        properties.map {|name, attrs|
          Property.new(name, attrs).to_openapi
        }.inject {|acc, hash|
          acc.merge(hash)
        }
      end

      def initialize(name, attrs)
        @name  = name
        @attrs = attrs

        @attrs["properties"] = Property.array_to_openapi(@attrs["properties"]) if @attrs.has_key?("properties")
      end

      def to_openapi
        if nullable?
          attrs = @attrs.merge({
            "type" => type_without_null,
            "x-nullable" => true
          })
        else
          attrs = @attrs
        end

        {@name => attrs}
      end

      def nullable?
        @attrs["type"].is_a?(Array) && @attrs["type"].member?("null")
      end

      def type_without_null
        type = @attrs["type"].select {|t| t != "null"}
        type.size == 1 ? type.first : type
      end
    end
  end
end
