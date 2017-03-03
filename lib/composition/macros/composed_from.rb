module Composition
  module Macros
    module ComposedFrom
      extend ActiveSupport::Concern

      def method_missing(method_name, *args, &block)
        if match_attribute?(method_name)
          Composition::Builders::ComposedFrom.new(self).def_composition_setters
          send(method_name, *args, &block)
        else
          super
        end
      end

      def respond_to?(method_name, include_private = false)
        if match_attribute?(method_name)
          Composition::Builders::ComposedFrom.new(self).def_composition_setters
          true
        else
          super
        end
      end

      private

      def match_attribute?(method_id)
        if method_id.to_s.match(/=$/)
          attribute = method_id.to_s.gsub(/=$/, '')
          reflection = _composition_reflections.first.try(:last)
          reflection.aliases.include?(attribute.to_sym)
        end
      end

      class_methods do
        def composed_from(*args)
          composed_from = args.shift
          options = args.last || {}
          options = {
            composed_from: composed_from,
            class_name: options[:class_name] || composed_from.to_s.camelize,
            inverse_of: options[:inverse_of] || model_name.name
          }
          composition = Compositions::ComposedFrom.new(options[:composed_from], options)
          add_composition_reflection(self, options[:inverse_of], composition)
        end
      end
    end
  end
end
