module Composition
  module Compositions
    class ComposedFrom < ::Composition::Compositions::Composition
      delegate :mapping, to: :inverse_of_composition

      # For a composition defined like:
      #
      #  class User < ActiveRecord::Base
      #    compose :credit_card,
      #            mapping: {
      #              credit_card_name: :name,
      #              credit_card_brand: :brand
      #            }
      #  end
      #
      #  class CreditCard < Composition::Base
      #    composed_from :user
      #  end
      #
      # The setter method will be in charge of implementing @credit_card.name= and @credit_card.brand=.
      #
      # If calling @credit_card.name= it will take care of updating the @name instance variable in
      # @credit_card, but also will take care of keeping @user.credit_card_name in sync with it.
      def setter(obj, setter_attr, setter_value)
        set_instance_variable(obj, setter_attr, setter_value)
        set_parent_attribute(obj, setter_attr, setter_value)
        setter_value
      end

      #TODO: Add documentation
      def attributes(obj)
        aliases.each_with_object({}) do |attr, memo|
          value = obj.send(attr)
          if value.respond_to?(:attributes)
            memo[attr] = value.send(:attributes)
          else
            memo[attr] = value
          end
        end
      end

      def aliases
        mapping.values
      end

      private

      def set_instance_variable(obj, setter_attr, setter_value)
        obj.instance_variable_set("@#{setter_attr}", setter_value)
      end

      def set_parent_attribute(obj, setter_attr, setter_value)
        parent = parent_for(obj)

        if parent
          parent_composition = parent._composition_reflections[inverse_of]
          parent.send("#{parent_composition.actual_column_for(setter_attr)}=", setter_value)
        end
      end

      def inverse_of_composition
        klass._composition_reflections[inverse_of]
      end

      # A composition class can have more than one reference, but only one parent should be not nil
      # at the same time.
      def parent_for(obj)
        obj._composition_reflections.map { |_, composition| obj.send(composition.name).presence }.compact.first
      end
    end
  end
end
