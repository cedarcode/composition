# Composition

[![Build Status](https://travis-ci.org/marceloeloelo/composition.svg?branch=master)](https://travis-ci.org/marceloeloelo/composition)
[![Code Climate](https://codeclimate.com/github/marceloeloelo/composition/badges/gpa.svg)](https://codeclimate.com/github/marceloeloelo/composition)
[![Gem Version](https://badge.fury.io/rb/composition.svg)](https://badge.fury.io/rb/composition)

Alternative composition support for `rails` applications, for when
ActiveRecord's `composed_of` is not enough. This gem adds some behavior
into composed objects and ways to interact and send messages between both
the one composing and the one being composed.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'composition'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install composition

## Usage

Composition will enable a new way of defining composed objects into an
ActiveRecord class. You should have available a `compose` macro for your
use in your application models.

```ruby
class User < ActiveRecord::Base
  compose :credit_card,
          mapping: {
            credit_card_name: :name,
            credit_card_brand: :brand,
            credit_card_expiration: :expiration
          }
end
```

The `User` class has now available the following methods to manipulate
the `credit_card` object:
* `User#credit_card`
* `User#credit_card=(credit_card)`

These methods will operate with a credit_card value object like the one
described below:
```ruby
class CreditCard < Composition::Base
  composed_from :user

  def expired?
    Date.today > expiration
  end
end
```

Notice that `CreditCard` inherits from `Composition::Base` and that the
`composed_from` macro is set to `:user`. This is necessary in order to gain
full access to the `user` object from the `credit_card`.
 
### How to interact with the value object
With the previous setup in place, now it should be possible to access attributes from
the database through the value objects instead. You can think of the `CreditCard`
as a normal `ActiveModel::Model` class with the attributes that you already
specified in the `mapping` option.

You would interact with the credit_card object like the following:
```ruby
user.credit_card_name  = 'Jon Snow'          # Set the ActiveRecord attribute
user.credit_card_brand = 'Visa'              # Set the ActiveRecord attribute
user.credit_card_expiration = Date.yesterday # Set the ActiveRecord attribute

user.credit_card                    # => CreditCard.new(name: 'Jon Snow', brand: 'Visa', expiration: Thu, 11 May 2017)
user.credit_card.name               # => 'Jon Snow'
user.credit_card.brand              # => 'Visa'
user.credit_card.expiration         # => Thu, 11 May 2017
user.credit_card.user == user       # => true
user.credit_card.attributes         # => { name: 'Jon Snow', brand: 'Visa', expiration: Thu, 11 May 2017 }

user.credit_card.expired?           # => true
```

Modifying the credit_card attributes:
```ruby
user.credit_card.name                # => 'Jon Snow'
user.credit_card.name = 'Arya Stark' # => 'Arya Stark'
user.credit_card_name                # => 'Arya Stark'
user.save                            # => true
```

### Writing to value objects
The value object can be set by either setting attributes individually, by
assigning a new value object, or by using `assign_attributes` on the parent.

```ruby
user.credit_card.name = 'Jon Snow'
user.credit_card.brand = 'Visa'
user.credit_card.expiration = Date.today
user.credit_card # => CreditCard.new(name: 'Jon Snow', brand: 'Visa', expiration: Thu, 12 May 2017)

user.credit_card = CreditCard.new(name: 'Jon Snow', brand: 'Visa', expiration: Date.today)
user.credit_card # => CreditCard.new(name: 'Jon Snow', brand: 'Visa', expiration: Thu, 12 May 2017)

user.assign_attributes(credit_card: { name: 'Jon Snow', brand: 'Visa', expiration: Date.today })
user.credit_card # => CreditCard.new(name: 'Jon Snow', brand: 'Visa', expiration: Thu, 12 May 2017)

user.update_attributes(credit_card: { name: 'Jon Snow', brand: 'Visa', expiration: Date.today })
user.credit_card # => CreditCard.new(name: 'Jon Snow', brand: 'Visa', expiration: Thu, 12 May 2017)
```

### Validations
If you need to add validations to your value object that should just work.

```ruby
class CreditCard < Composition::Base
  composed_from :user

  validates :expiration, presence: true

  def expired?
    Date.today > expiration
  end
end

user.credit_card = CreditCard.new(name: 'Jon Snow', brand: 'Visa', expiration: nil)
user.credit_card.valid? # => false
```

### Detailed macro documentation
Composition will assume some things and use some defaults based on naming
conventions for when you define `compose` and `composed_from` macros. However,
there will be cases where you will have to override the naming convention with
something custom. Following you will find the complete reference for the provided
macros.

#### Options for compose
The `compose` method will accept the following options:

##### :mapping 
This is required. It will accept a hash of mappings between the attributes
in the parent object and their mapping to the new value object being defined.

```ruby
class User < ActiveRecord::Base
  compose :credit_card,
          mapping: {
            credit_card_name: :name,
            credit_card_brand: :brand,
            credit_card_expiration: :expiration
          }
end
```

##### :class_name
Optional. If the name of the value object cannot be derived from the composition
name, you can use the `:class_name` option to supply the class name. If a `user` has
a `credit_card` but the name of the class is something like `CCard`, then you can use:

```ruby
class User < ActiveRecord::Base
  compose :credit_card,
          mapping: {
            credit_card_name: :name,
            credit_card_brand: :brand,
            credit_card_expiration: :expiration
          }, class_name: 'CCard'
end
```

#### Options for composed_from
The `composed_from` method will accept the following options:

##### :class_name
Optional. If the name of the value object cannot be derived from the composition
name, you can use the `:class_name` option to supply the class name. If a `user` has
a `credit_card` but the name of the user class is something like `AdminUser`, then
you can use:

```ruby
class CreditCard < Composition::Base
  compose_from :user, class_name: 'AdminUser'
end
```


## Contributing

1. Fork it ( https://github.com/marceloeloelo/composition/ )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

See the [Running Tests](RUNNING_TESTS.md) guide for details on how to run the test suite.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
