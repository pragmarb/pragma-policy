# frozen_string_literal: true
module Pragma
  module Policy
    # The attribute authorizer provides attribute-level authorization for resource updates.
    #
    # It allows you to specify whether a resource attribute can be changed and, if you want, what
    # values should be allowed.
    #
    # If you want, you can subclass this base authorizer to avoid repeating code.
    #
    # @author Alessandro Desantis
    class AttributeAuthorizer
      # @!attribute [r] resource
      #   @return [ActiveRecord::Base|Reform::Form] the resource being authorized
      #
      # @!attribute [r] attribute
      #   @return [Symbol] the attribute being authorized
      attr_reader :resource, :attribute

      # Initializes the authorizer.
      #
      # @param resource [ActiveRecord::Base|Reform::Form] the resource being authorized
      # @param attribute [Symbol] the attribute being authorized
      #
      # @raise [UnknownEngineError] if the resource is not based on Reform or ActiveRecord
      def initialize(resource:, attribute:)
        @resource = resource
        @attribute = attribute

        validate_resource
      end

      # Returns the old value of the attribute (if any).
      #
      # For Reform, this retrieves the current value of the attribute from the model. For
      # ActiveRecord, uses the +<attribute>_was+ method.
      #
      # @return [Object|NilClass]
      def old_value
        case resource_engine
        when :reform
          resource.model.send(attribute)
        when :active_record
          resource.send("#{attribute}_was")
        end
      end

      # Returns the new (i.e. current) value of the attribute.
      #
      # Simply sends the attribute name to the resource.
      #
      # @return [Object]
      def new_value
        resource.send(attribute)
      end

      # Returns whether the attribute has changed, by comparing the new and the old value.
      #
      # @return [Boolean]
      def changed?
        old_value != new_value
      end

      # Returns the engine used for the resource being authorized (Reform or ActiveRecord).
      #
      # @return [Symbol] +:reform+ or +:active_record+
      #
      # @raise [UnknownEngineError] if the engine cannot be detected
      def resource_engine
        if defined?(Reform::Form) && resource.is_a?(Reform::Form)
          :reform
        elsif defined?(ActiveRecord::Base) && resource.is_a?(ActiveRecord::Base)
          :active_record
        else
          fail UnknownEngineError(resource: resource, attribute: attribute)
        end
      end

      # Ensures that the attribute was changed according to the provided options.
      #
      # When neither +only+ nor +except+ are passed, simply ensures that the attribute was not
      # changed.
      #
      # When +only+ is passed and is not empty, ensures that the value is part of the given array.
      #
      # When +except+ is passed and not empty, also ensures that the value is NOT part of the given
      # array.
      #
      # @param options [Hash] a hash of options
      #
      # @option options [Array<String>] :only an optional list of allowed values
      # @option options [Array<String>] :except an optional list of forbidden values
      #
      # @return [Boolean] whether the attribute has an authorized value
      def authorize(options = {})
        options[:only] = ([options[:only]] || []).flatten.map(&:to_s).reject(&:empty?)
        options[:except] = ([options[:except]] || []).flatten.map(&:to_s).reject(&:empty?)

        if options[:only].any? && options[:except].any?
          fail(
            ArgumentError,
            'The :only and :except options cannot be used at the same time.'
          )
        end

        return true unless changed?

        if options[:only].any?
          options[:only].include?(new_value.to_s)
        elsif options[:except].any?
          !options[:except].include?(new_value.to_s)
        end || false
      end

      private

      def validate_resource
        resource_engine
      end

      # This error when the engine behind a resource cannot be detected for attribute authorization.
      #
      # @author Alessanro Desantis
      class UnknownEngineError < StandardError
        MESSAGE = 'Attribute authorization only works with Reform forms and ActiveRecord models.'

        # @!attribute [r] resource
        #   @return [Object] the resource
        attr_reader :resource

        # Initializes the error.
        #
        # @param resource [Object] the resource
        def initialize(resource:)
          @resource = resource

          super MESSAGE
        end
      end
    end
  end
end
