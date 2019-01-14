# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Queries::Users::VaProfileQuery do
  let(:user) { build(:user, :loa3) }
  let(:query) do
    <<-GRAPHQL
      query {
        userVaProfile {
          status
          birthDate
          familyName
          gender
          givenNames
          errors {
            type
            message
          }
        }
      }
    GRAPHQL
  end

  let(:response) { VetsAPISchema.execute(query, context: { current_user: user }) }
  let(:results) { response.dig('data', 'userVaProfile') }
  let(:fields) do
    %w[
      birthDate
      familyName
      gender
      givenNames
    ]
  end

  it 'returns a status of OK' do
    expect(results['status']).to eq 'OK'
  end

  it 'returns the expected VA profile data', :aggregate_failures do
    fields.each do |field|
      expect(results[field]).to eq user.va_profile.send(field.underscore)
    end
  end

  it 'returns no errors' do
    expect(response.dig('data', 'errors')).to be_nil
  end

  context 'with a non-OK status' do
    let(:server_error) { 'SERVER_ERROR' }

    before do
      allow(user).to receive(:va_profile_status).and_return(server_error)
    end

    let(:response) { VetsAPISchema.execute(query, context: { current_user: user }) }
    let(:results) { response.dig('data', 'userVaProfile') }

    it 'returns the non-OK status' do
      expect(results['status']).to eq server_error
    end

    it 'sets all of the va_profile fields to nil', :aggregate_failures do
      fields.each do |field|
        expect(results[field]).to be_nil
      end
    end

    it 'returns no errors' do
      expect(results['errors']).to be_nil
    end
  end

  context 'with an error' do
    before do
      allow(user).to receive(:va_profile).and_raise(StandardError, 'some error')
    end

    it 'returns error details', :aggregate_failures do
      response = VetsAPISchema.execute(query, context: { current_user: user })
      errors   = response.dig('data', 'userVaProfile', 'errors')

      expect(errors.dig('type')).to eq 'StandardError'
      expect(errors.dig('message')).to eq 'some error'
    end
  end
end
