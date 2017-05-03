module InterpolToOpenAPI
  module Interpol
    class Schema
      def initialize(schema)
        @schema = schema
      end

      def to_openapi
        converted = @schema.map do |key, val|
          case key
          when "properties"
            [key, x_nullable(val)]
          else
            [key, val]
          end
        end

        Hash[converted]
      end

      private

      def x_nullable(properties)
        converted = properties.map do |key, val|
          if val.is_a?(Hash)
            if val["type"].is_a?(Array)
              [key, extract_nullable(val)]
            elsif val.has_key?("properties")
              [key, Schema.new(val).to_openapi]
            else
              [key, val]
            end
          else
            [key, val]
          end
        end

        Hash[converted]
      end

      def extract_nullable(prop)
        if prop["type"].member? "null"
          prop.merge({
            "type" => type_without_null(prop["type"]),
            "x-nullable" => true
          })
        else
          prop
        end
      end

      def type_without_null(type)
        new_type = type.select {|t| t != "null"}

        if new_type.size == 1
          new_type.first
        else
          new_type
        end
      end
    end
  end
end
