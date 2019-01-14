# frozen_string_literal: true

module Queries
  # The parent list of potential queries that are made available to
  # the GraphQL schema, VetsAPISchema.
  #
  # This list is comprised of individual lists (or manifests), each
  # one containing their own assembly of available queries.
  #
  class Query < Types::BaseObject
    include Queries::Users::QueryManifest
  end
end
