module Composition
  module Builders
    class Compose
      attr_reader :object
      delegate :_composition_reflections, to: :object

      def initialize(object)
        @object = object
      end

      def def_composition_methods
        _composition_reflections.each_value do |composition|
          def_composition_getter(composition)
          def_composition_setter(composition)
        end
      end

      private

      def def_composition_getter(composition)
        define_method(composition.name) { composition.getter(self) }
      end

      def def_composition_setter(composition)
        define_method("#{composition.name}=") { |setter_value| composition.setter(self, setter_value) }
      end

      def define_method(method_name, &block)
        @object.class.send(:define_method, method_name, &block)
      end
    end
  end
end
