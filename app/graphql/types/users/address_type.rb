# frozen_string_literal: true

module Types
  module Users
    class AddressType < Types::BaseObject
      field :address_line1, String, null: false
      field :address_line2, String, null: true
      field :address_line3, String, null: true
      field :address_pou, String, null: false
      field :address_type, String, null: false
      field :city, String, null: false
      field :country_name, String, null: false
      field :country_code_iso2, String, null: true
      field :country_code_iso3, String, null: true
      field :county_code, String, null: true
      field :county_name, String, null: true
      field :created_at, String, null: true
      field :effective_end_date, String, null: true
      field :effective_start_date, String, null: true
      field :id, Integer, null: true
      field :international_postal_code, String, null: true
      field :source_date, String, null: false
      field :state_code, String, null: true
      field :transaction_id, String, null: true
      field :updated_at, String, null: true
      field :vet360_id, String, null: true
      field :zip_code, String, null: true
      field :zip_code_suffix, String, null: true
    end
  end
end
