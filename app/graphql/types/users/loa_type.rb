# frozen_string_literal: true

module Types
  module Users
    class LoaType < Types::BaseObject
      field :current, Integer, null: false
      field :highest, Integer, null: false
    end
  end
end
