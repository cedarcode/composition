module Composition
  module Compositions
    class Compose < ::Composition::Compositions::Composition

      # For a composition defined like:
      #
      #   class User < ActiveRecord::Base
      #     compose :credit_card,
      #             mapping: {
      #               credit_card_name: :name,
      #               credit_card_brand: :brand
      #             }
      #   end
      #
      # The getter method will be in charge of implementing @user.credit_card.
      #
      # It is responsible for instantiating a new CreditCard object with the attributes
      # from the de-normalized columns in User, and then return it.
      def getter(ar)
        attributes = attributes(ar)
        klass.new(attributes.merge(composed_from.name => ar)).tap(&:valid?) unless all_blank?(attributes)
      end

      # For a composition defined like:
      #
      #   class User < ActiveRecord::Base
      #     compose :credit_card,
      #             mapping: {
      #               credit_card_name: :name,
      #               credit_card_brand: :brand
      #             }
      #   end
      #
      # The setter method will be in charge of implementing @user.credit_card=.
      #
      # setter_value can be either a credit_card instance or a hash of attributes
      # and the setter will only set the @credit_card attributes that are included
      # in the hash. This means that if a credit_card attribute is not given in the hash
      # then we'll set it with the value from the @user de-normalized column. The reason
      # behind this is to imitate how ActiveRecord assign_attributes method works.
      def setter(ar, setter_value)
        nil_columns(ar) and return if setter_value.nil?
        attributes = setter_value.to_h.with_indifferent_access

        mapping.each do |actual_column, composed_alias|
          ar.send("#{actual_column}=", attributes[composed_alias]) if attributes.key?(composed_alias)
        end

        setter_value
      end

      def mapping
        @options[:mapping]
      end

      def actual_column_for(aliased_attribute)
        mapping.key(aliased_attribute)
      end

      private

      # Returns the hash of attributes for instantiating the composition defined for a given
      # class.
      def attributes(ar)
        mapping.each_with_object({}) do |(actual_column, composed_alias), memo|
          memo[composed_alias] = ar.send(actual_column)
        end
      end

      def all_blank?(attributes = {})
        attributes.all? { |_, value| value.blank? }
      end

      def nil_columns(ar)
        mapping.each { |actual_column, _| ar.send("#{actual_column}=", nil) }
      end

      # TODO: Add descriptive error if find returns nil. "composed_from is missing"
      def composed_from
        klass._composition_reflections.find { |_, composition| composition.class_name == inverse_of }.last
      end
    end
  end
end
