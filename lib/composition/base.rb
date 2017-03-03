module Composition
  class Base
    include ActiveModel::Model
    include Composition::Reflection
    include Composition::Macros::ComposedFrom
  end
end
