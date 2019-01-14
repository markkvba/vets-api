# frozen_string_literal: true

module Types
  module Users
    class VaProfileType < Types::BaseObject
      field :status, String, null: true
      field :birth_date, String, null: true
      field :family_name, String, null: true
      field :gender, String, null: true
      field :given_names, [String], null: true
      field :errors, Types::ErrorType, null: true

      def status
        object.dig(:status)
      end

      def birth_date
        va_profile&.birth_date
      end

      def family_name
        va_profile&.family_name
      end

      def gender
        va_profile&.gender
      end

      def given_names
        va_profile&.given_names
      end

      def errors
        error_details object.dig(:errors)
      end

      private

      def va_profile
        object.dig(:va_profile)
      end
    end
  end
end
