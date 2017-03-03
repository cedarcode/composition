module Composition
  module Reflection
    extend ActiveSupport::Concern

    included do
      class_attribute :_composition_reflections, instance_writer: false
      self._composition_reflections = {}.with_indifferent_access
    end

    class_methods do
      def add_composition_reflection(obj, name, reflection)
        new_reflection = { name => reflection }.with_indifferent_access
        obj._composition_reflections = obj._composition_reflections.merge(new_reflection)
      end
    end
  end
end

ActiveRecord::Base.send(:include, Composition::Reflection)
