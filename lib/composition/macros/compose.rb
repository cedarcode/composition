module Composition
  module Macros
    module Compose
      extend ActiveSupport::Concern

      def method_missing(method_name, *args, &block)
        if match_composition?(method_name)
          Composition::Builders::Compose.new(self).def_composition_methods
          send(method_name, *args, &block)
        else
          super
        end
      end

      def respond_to?(method_name, include_private = false)
        if match_composition?(method_name)
          Composition::Builders::Compose.new(self).def_composition_methods
          true
        else
          super
        end
      end

      private

      def match_composition?(method_id)
        composition_name = method_id.to_s.gsub(/=$/, '')
        _composition_reflections.any? { |_, composition| composition_name == composition.name.to_s }
      end

      class_methods do
        def compose(*args)
          composed_attribute = args.shift
          options = args.last || {}
          options = {
            composed_attribute: composed_attribute,
            mapping: options[:mapping],
            class_name: options[:class_name] || composed_attribute.to_s.camelize,
            inverse_of: options[:inverse_of] || model_name.name
          }
          composition = Compositions::Compose.new(options[:composed_attribute], options)
          add_composition_reflection(self, options[:class_name], composition)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Composition::Macros::Compose)
