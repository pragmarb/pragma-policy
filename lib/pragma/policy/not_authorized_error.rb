# frozen_string_literal: true
module Pragma
  module Policy
    class NotAuthorizedError < Pundit::NotAuthorizedError
    end
  end
end
