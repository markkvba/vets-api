# frozen_string_literal: true

module Queries
  module Users
    class Vet360ContactInformationQuery < Queries::BaseQuery
      description "The user's Vet360 contact information details"

      type Types::Users::Vet360ContactInformationType, null: false

      def resolve
        current_user = context[:current_user]
        person       = current_user.vet360_contact_info

        vet360_response person
      rescue StandardError => e
        vet360_response person, e
      end

      private

      def vet360_response(person, errors = nil)
        {
          person: person,
          errors: errors
        }
      end
    end
  end
end
