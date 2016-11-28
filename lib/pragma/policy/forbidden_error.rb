module Pragma
  module Policy
    # This error is raised when a user attempts to perform an unauthorized operation on a resource.
    #
    # @author Alessandro Desantis
    class ForbiddenError < StandardError
      # @!attribtue [r] user
      #   @return [Object] the user operating on the resource
      #
      # @!attribute [r] action
      #   @return [Symbol] the attempted action
      #
      # @!attribute [r] resource
      #   @return [Object] the resource being operated on
      attr_reader :user, :action, :resource

      # Initializes the error.
      #
      # @param user [Object] the user operating on the resource
      # @param action [Symbol] the attempted action
      # @param resource [Object] the resource being operated on
      def initialize(user:, action:, resource:)
        @user = user
        @action = action.to_sym
        @resource = resource

        super("User is not authorized to perform action '#{action}' on this resource.")
      end
    end
  end
end
