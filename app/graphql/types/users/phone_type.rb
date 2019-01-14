# frozen_string_literal: true

module Types
  module Users
    class PhoneType < Types::BaseObject
      field :area_code, String, null: false
      field :country_code, String, null: false
      field :created_at, String, null: true
      field :extension, String, null: true
      field :id, Integer, null: true
      field :is_international, Boolean, null: true
      field :is_voicemailable, Boolean, null: true
      field :phone_number, String, null: false
      field :phone_type, String, null: false
      field :source_date, String, null: true
      field :transaction_id, String, null: true
      field :is_tty, Boolean, null: true
      field :updated_at, String, null: true
      field :vet360_id, String, null: true
      field :effective_end_date, String, null: true
      field :effective_start_date, String, null: true
    end
  end
end
