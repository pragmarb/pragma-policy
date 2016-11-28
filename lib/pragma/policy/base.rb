module Pragma
  module Policy
    # This is the base policy class that all your resource-specific policies should inherit from.
    #
    # A policy provides predicate methods for determining whether a user can perform a specific
    # action on a resource.
    #
    # @author Alessandro Desantis
    #
    # @abstract Subclass and implement action methods to create a policy.
    class Base
      # @!attribute [r] user
      #   @return [Object] the user operating on the resource
      #
      # @!attribute [r] resource
      #   @return [Object] the resource being operated on
      attr_reader :user, :resource

      # Initializes the policy.
      #
      # @param user [Object] the user operating on the resource
      # @param resource [Object] the resource being operated on
      def initialize(user:, resource:)
        @user = user
        @resource = resource
      end

      # Returns whether the policy responds to the provided missing method.
      #
      # Supports bang forms of predicates (+create!+, +update!+ etc.).
      #
      # @param method_name [String] the method name
      # @param include_private [Boolean] whether to consider private methods
      #
      # @return [Boolean]
      def respond_to_missing?(method_name, include_private = false)
        return super unless method_name[-1] == '!'
        respond_to?("#{method_name[0..-2]}?", include_private) || super
      end

      # Provides bang form of predicates (+create!+, +update!+ etc.).
      #
      # @param method_name [String] the method name
      # @param *args [Array<Object>] the method arguments
      #
      # @return [Object]
      def method_missing(method_name, *args, &block)
        return super unless method_name[-1] == '!'
        authorize method_name[0..-2], *args
      end

      # Authorizes the user to perform the given action. If not authorized, raises a
      # {ForbiddenError}.
      #
      # @param action [Symbol] the action to authorize
      #
      # @raise [ArgumentError] if the action is not defined in this policy
      # @raise [ForbiddenError] if the user is not authorized to perform the action
      def authorize(action)
        fail(
          ArgumentError,
          "'#{action}' is not a valid action for this policy."
        ) unless respond_to?("#{action}?")

        fail(
          ForbiddenError,
          user: user,
          action: action,
          resource: resource
        ) unless send("#{action}?")
      end
    end
  end
end
