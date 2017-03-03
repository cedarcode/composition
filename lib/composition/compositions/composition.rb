module Composition
  module Compositions
    class Composition

      attr_reader :name

      def initialize(name, options = {})
        @name = name
        @options = options
      end

      def class_name
        @options[:class_name]
      end

      def klass
        class_name.constantize
      end

      def inverse_of
        @options[:inverse_of]
      end
    end
  end
end
