# Pragma::Policy

[![Build Status](https://img.shields.io/travis/pragmarb/pragma-policy.svg?maxAge=3600&style=flat-square)](https://travis-ci.org/pragmarb/pragma-policy)
[![Dependency Status](https://img.shields.io/gemnasium/pragmarb/pragma-policy.svg?maxAge=3600&style=flat-square)](https://gemnasium.com/github.com/pragmarb/pragma-policy)
[![Code Climate](https://img.shields.io/codeclimate/github/pragmarb/pragma-policy.svg?maxAge=3600&style=flat-square)](https://codeclimate.com/github/pragmarb/pragma-policy)
[![Coveralls](https://img.shields.io/coveralls/pragmarb/pragma-policy.svg?maxAge=3600&style=flat-square)](https://coveralls.io/github/pragmarb/pragma-policy)

Policies provide fine-grained access control for your API resources.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pragma-policy'
```

And then execute:

```console
$ bundle
```

Or install it yourself as:

```console
$ gem install pragma-policy
```

## Usage

To create a policy, simply inherit from `Pragma::Policy::Base`:

```ruby
module API
  module V1
    module Article
      class Policy < Pragma::Policy::Base
      end
    end
  end
end
```

By default, the policy does not return any objects and forbids all operations.

You can start customizing your policy by defining a scope and operation predicates:

```ruby
module API
  module V1
    module Article
      class Policy < Pragma::Policy::Base
        class Scope < Pragma::Policy::Base::Scope
          def resolve
            scope.where('published = ? OR author_id = ?', true, user.id)
          end
        end

        def show?
          resource.published? || resource.author_id == user.id
        end

        def update?
          resource.author_id == user.id
        end

        def destroy?
          resource.author_id == user.id
        end
      end
    end
  end
end
```

You are ready to use your policy!

### Retrieving Records

To retrieve all the records accessible by a user, use the `.accessible_by` class method:

```ruby
posts = API::V1::Article::Policy::Scope.new(user, Article.all).resolve
```

### Authorizing Operations

To authorize an operation, first instantiate the policy, then use the predicate methods:

```ruby
policy = API::V1::Article::Policy.new(user, post)
fail 'You cannot update this post!' unless policy.update?
```

Since raising when the operation is forbidden is so common, we provide bang methods a shorthand
syntax. `Pragma::Policy::NotAuthorizedError` is raised if the predicate method returns `false`:

```ruby
policy = API::V1::Article::Policy.new(user: user, resource: post)
policy.update! # raises if the user cannot update the post
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pragmarb/pragma-policy.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
