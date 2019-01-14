# frozen_string_literal: true

namespace :graphql do
  # @see http://rmosolgo.github.io/blog/2017/03/16/tracking-schema-changes-with-graphql-ruby/
  #
  desc 'Updates the GraphQL schema definition'
  task dump_schema: :environment do
    schema_defn = VetsAPISchema.to_definition
    schema_path = 'app/graphql/schema.graphql'

    File.write(Rails.root.join(schema_path), schema_defn)
    puts "Updated #{schema_path}"
  end
end
