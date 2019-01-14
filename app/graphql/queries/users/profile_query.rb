# frozen_string_literal: true

module Queries
  module Users
    class ProfileQuery < Queries::BaseQuery
      description "The user's profile details"

      type Types::Users::ProfileType, null: false

      def resolve
        context[:current_user]
      end
    end
  end
end
