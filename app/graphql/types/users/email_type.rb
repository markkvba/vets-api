# frozen_string_literal: true

module Types
  module Users
    class EmailType < Types::BaseObject
      field :created_at, String, null: true
      field :email_address, String, null: false
      field :effective_end_date, String, null: true
      field :effective_start_date, String, null: true
      field :id, Integer, null: true
      field :source_date, String, null: true
      field :transaction_id, String, null: true
      field :updated_at, String, null: true
      field :vet360_id, String, null: true
    end
  end
end
