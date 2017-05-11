module Composition
  module Testing
    module ModelMacros
      def spawn_model(klass, &block)
        Object.instance_eval { remove_const klass } if Object.const_defined?(klass)
        Object.const_set klass, Class.new(ActiveRecord::Base)
        Object.const_get(klass).class_eval(&block) if block_given?
        @spawned_models << klass.to_sym
      end

      def spawn_composition(klass, &block)
        Object.instance_eval { remove_const klass } if Object.const_defined?(klass)
        Object.const_set klass, Class.new(Composition::Base)
        Object.const_get(klass).class_eval(&block) if block_given?
        @spawned_compositions << klass.to_sym
      end

      def create_table(table_name)
        ActiveRecord::Migration.suppress_messages do
          ActiveRecord::Schema.define do
            create_table table_name, force: true do |t|
              yield(t)
            end
          end
        end
      end
    end
  end
end
