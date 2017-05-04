require_relative "property"

module InterpolToOpenAPI
  module Interpol
    class Schema
      def initialize(schema)
        @schema = schema
      end

      def to_openapi
        update = {}
        update["properties"] = Property.array_to_openapi(@schema["properties"]) if @schema.has_key?("properties")

        @schema.merge(update)
      end
    end
  end
end
