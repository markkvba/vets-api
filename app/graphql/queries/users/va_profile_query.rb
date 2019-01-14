# frozen_string_literal: true

module Queries
  module Users
    class VaProfileQuery < Queries::BaseQuery
      include Common::Client::ServiceStatus

      description "The user's VA Profile details"

      type Types::Users::VaProfileType, null: false

      def resolve
        current_user = context[:current_user]
        status       = current_user.va_profile_status
        va_profile   = va_profile_for(current_user, status)

        va_profile_response status, va_profile
      rescue StandardError => e
        va_profile_response status, va_profile, e
      end

      private

      def va_profile_for(current_user, status)
        status == RESPONSE_STATUS[:ok] ? current_user.va_profile : nil
      end

      def va_profile_response(status, va_profile = nil, errors = nil)
        {
          status: status,
          va_profile: va_profile,
          errors: errors
        }
      end
    end
  end
end
