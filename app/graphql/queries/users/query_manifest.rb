# frozen_string_literal: true

module Queries
  module Users
    # Module that:
    #   - lists all of the User queries
    #   - assigns a field name to each query
    #   - maps a given field name to a resolver
    #
    module QueryManifest
      extend ActiveSupport::Concern

      included do
        field :user_account, resolver: Queries::Users::AccountQuery
        field :user_profile, resolver: Queries::Users::ProfileQuery
        field :user_va_profile, resolver: Queries::Users::VaProfileQuery
      end
    end
  end
end
