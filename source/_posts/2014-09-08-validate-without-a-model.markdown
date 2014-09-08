---
title: "ActiveModel validations without a model"
categories:
- programming
published: true
---
The other day someone on Stack Overflow asked [how to validate inputs without having a model](http://stackoverflow.com/questions/25460319/rails-validate-input-without-need-of-models).

I kind of liked [my answer](http://stackoverflow.com/a/25461530/33245), so I am more or less reposting it here &mdash; with some extra thoughts.

<!--more-->

## The Rails Way (tm)

The Rails Way is having validations tied to `ActiveRecord` classes, and where that doesn’t make sense, construct other classes and include `ActiveModel::Validations`.

Occasionally this might be too heavy-handed, I guess, or you might have dynamic validations, or you might disagree with having validations in the model layer on sheer principle.

## The Laravel Way?

The original question used an example from [Laravel](http://laravel.com/), where validations do not live inside models. Rather, you construct a validator that can tell you if a set of inputs is valid given a set of validations.

An action following that pattern might look like this in a Rails application:

````ruby
validator = DataValidator.make(
  params,
  {
    :email => {:presence => true},
    :name => {:presence => true}
  }
)
if validator.valid?
  # Success
else
  # Error
	@errors = validator.errors
end
````

Simple enough, huh?

The code for this is fairly simple as well and basically defines an anonymous class on the fly, returning an instance of that class:

````ruby
class DataValidator
  def self.make(data, validations)
    Class.new do
      include ActiveModel::Validations

      attr_accessor(*validations.keys)

      validations.each do |attribute, options|
        validates attribute, options
      end

      def self.model_name
        ActiveModel::Name.new(self, nil, "DataValidator::Validator")
      end

      def initialize(data)
        data.each do |key, value|
          self.send("#{key.to_sym}=“, value)
        end
      end
    end.new(data)
  end
end
````

## What's up with validating data in models, anyways?

Writing the above code also got me thinking; why exactly do we not always validate inputs like this? Why do we insist on validating user input in our models?
