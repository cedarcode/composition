module Composition
  module Builders
    class ComposedFrom
      attr_reader :object
      delegate :_composition_reflections, to: :object

      def initialize(object)
        @object = object
      end

      # TODO: add documentation
      def def_composition_setters
        _composition_reflections.each_value do |composition|
          composition.aliases.each do |attr|
            def_attr_reader(attr)
            define_method("#{attr}=") { |setter_value| composition.setter(self, attr, setter_value) }
            define_method(:attributes) { composition.attributes(self) }
            define_method(:to_h) { composition.attributes(self) }
          end
          def_attr_accessor(composition.name)
        end
      end

      private

      def define_method(method_name, &block)
        @object.class.send(:define_method, method_name, &block)
      end

      def def_attr_accessor(*attr)
        @object.class.send(:attr_accessor, *attr)
      end

      def def_attr_reader(*attr)
        @object.class.send(:attr_reader, *attr)
      end
    end
  end
end
