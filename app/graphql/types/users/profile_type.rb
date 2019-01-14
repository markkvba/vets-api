# frozen_string_literal: true

module Types
  module Users
    # Defines the fields on Profile. Fields expose the data that may
    # be queried, and validated.
    #
    class ProfileType < Types::BaseObject
      field :email, String, null: false
      field :first_name, String, null: true
      field :middle_name, String, null: true
      field :last_name, String, null: true
      field :birth_date, String, null: true
      field :gender, String, null: true
      field :zip, String, null: true
      field :last_signed_in, String, null: true
      field :loa, Types::Users::LoaType, null: false
      field :multifactor, Boolean, null: true
      field :verified, Boolean, null: true
      field :authn_context, String, null: true

      def verified
        object.loa3?
      end
    end
  end
end
