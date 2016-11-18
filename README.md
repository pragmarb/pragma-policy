# Pragma::Policy

[![Build Status](https://img.shields.io/travis/pragmarb/pragma-policy.svg?maxAge=3600&style=flat-square)](https://travis-ci.org/pragmarb/pragma-policy)
[![Dependency Status](https://img.shields.io/gemnasium/pragmarb/pragma-policy.svg?maxAge=3600&style=flat-square)](https://gemnasium.com/github.com/pragmarb/pragma-policy)
[![Code Climate](https://img.shields.io/codeclimate/github/pragmarb/pragma-policy.svg?maxAge=3600&style=flat-square)](https://codeclimate.com/github/pragmarb/pragma-policy)
[![Coveralls](https://img.shields.io/coveralls/pragmarb/pragma-policy.svg?maxAge=3600&style=flat-square)](https://coveralls.io/github/pragmarb/pragma-policy)

Policys are form objects on steroids for your JSON API.

They are built on top of [Reform](https://github.com/apotonick/reform).

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
    module Post
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
    module Post
      class Policy < Pragma::Policy::Base
        def self.accessible_by(user:, scope:)
          scope.where('published = ? OR author_id = ?', true, user.id)
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

## Retrieving records

To retrieve all the records accessible by a user, use the `.accessible_by` class method:

```ruby
posts = API::V1::Post::Policy.accessible_by(user: user, scope: Post.all)
```

## Authorizing operations

To authorize an operation, first instantiate the policy, then use the predicate methods:

```ruby
policy = API::V1::Post::Policy.new(user: user, post: post)
raise 'You cannot update this post!' unless policy.update?
```

Since raising when the operation is forbidden is so common, we provide the `#authorize!` instance
method as a shorthand syntax. `Pragma::Policy::ForbiddenError` is raised if the predicate method
returns `false`:

```ruby
policy = API::V1::Post::Policy.new(user: user, post: post)
policy.authorize! :update # raises if the user cannot update the post
```

## Attribute-level authorization

In some cases, you'll want to prevent a user from updating a certain attribute. You can do that with
the `#authorize_attr` method:

```ruby
module API
  module V1
    module Post
      class Policy < Pragma::Policy::Base
        def update?
          # admins can do whatever they want
          return true if user.admin?

          (
            resource.author_id == user.id &&
            # regular users cannot change the 'featured' attribute
            authorize_attr(:featured)
          )
        end
      end
    end
  end
end
```

You can also allow specific values for an enumerated attribute:

```ruby
module API
  module V1
    module Post
      class Policy < Pragma::Policy::Base
        def update?
          # admins can do whatever they want
          return true if user.admin?

          (
            resource.author_id == user.id &&
            # regular users can only set status to 'draft' or 'published'
            authorize_attr(:status, only: ['draft', 'published'])
          )
        end
      end
    end
  end
end
```

Or you can invert the condition and specify the forbidden attributes:

```ruby
module API
  module V1
    module Post
      class Policy < Pragma::Policy::Base
        def update?
          # admins can do whatever they want
          return true if user.admin?

          (
            resource.author_id == user.id &&
            # regular users cannot set the status to 'rejected'
            authorize_attr(:status, except: ['rejected'])
          )
        end
      end
    end
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pragmarb/pragma-policy.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
