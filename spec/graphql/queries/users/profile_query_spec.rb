# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Queries::Users::ProfileQuery do
  let(:user) { build(:user, :loa3) }
  let(:query) do
    <<-GRAPHQL
      query {
        userProfile {
          email
          firstName
          middleName
          lastName
          birthDate
          gender
          zip
          lastSignedIn
          loa {
            current
            highest
          }
          multifactor
          verified
          authnContext
        }
      }
    GRAPHQL
  end

  let(:response) { VetsAPISchema.execute(query, context: { current_user: user }) }
  let(:results) { response.dig('data', 'userProfile') }
  let(:fields) do
    %w[
      email
      firstName
      middleName
      lastName
      birthDate
      gender
      zip
      multifactor
      authnContext
    ]
  end

  it 'returns the expected profile data', :aggregate_failures do
    fields.each do |field|
      expect(results[field]).to eq user.send(field.underscore)
    end
  end

  it 'returns the users loa details', :aggregate_failures do
    loa = results.dig('loa')

    expect(loa['current']).to eq user.loa.dig :current
    expect(loa['highest']).to eq user.loa.dig :highest
  end

  it 'returns the users last_signed_in datetime' do
    expect(results['lastSignedIn']).to eq user.last_signed_in.to_s
  end

  it 'returns whether or not the user is verified' do
    expect(results['verified']).to_not be_nil
  end
end
