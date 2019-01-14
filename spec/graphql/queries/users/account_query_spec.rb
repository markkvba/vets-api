# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Queries::Users::AccountQuery do
  let(:user) { build(:user, :accountable) }
  let(:account_uuid) { user.account_uuid }
  let(:query) do
    <<-GRAPHQL
      query {
        userAccount {
          accountUuid
          errors {
            type
            message
          }
        }
      }
    GRAPHQL
  end

  let(:response) { VetsAPISchema.execute(query, context: { current_user: user }) }
  let(:results) { response.dig('data', 'userAccount') }

  it 'returns the users#account_uuid' do
    expect(results.dig('accountUuid')).to eq account_uuid
  end

  it 'returns no errors' do
    expect(response.dig('data', 'errors')).to be_nil
  end

  context 'with an error' do
    before do
      allow(user).to receive(:account).and_raise(StandardError, 'some error')
    end

    it 'returns error details', :aggregate_failures do
      response = VetsAPISchema.execute(query, context: { current_user: user })
      errors   = response.dig('data', 'userAccount', 'errors')

      expect(errors.dig('type')).to eq 'StandardError'
      expect(errors.dig('message')).to eq 'some error'
    end
  end
end
