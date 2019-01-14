# frozen_string_literal: true

require 'rails_helper'

RSpec.describe do
  it 'has an up-to-date schema.graphql file' do
    current_defn  = VetsAPISchema.to_definition
    printout_defn = File.read(Rails.root.join('app/graphql/schema.graphql'))

    expect(current_defn).to eq(printout_defn), 'Update the printed schema with `bundle exec rake graphql:dump_schema`'
  end
end
