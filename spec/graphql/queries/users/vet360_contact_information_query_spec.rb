# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Queries::Users::Vet360ContactInformationQuery do
  let(:user) { build(:user, :loa3) }

  context 'the email field' do
    let(:query) do
      <<-GRAPHQL
        query {
          userVet360ContactInformation {
            email {
              createdAt
              effectiveEndDate
              effectiveStartDate
              emailAddress
              id
              sourceDate
              transactionId
              updatedAt
              vet360Id
            }
            errors {
              type
              message
            }
          }
        }
      GRAPHQL
    end

    let(:response) { VetsAPISchema.execute(query, context: { current_user: user }) }
    let(:results) { response.dig('data', 'userVet360ContactInformation') }
    let(:fields) do
      %w[
        createdAt
        emailAddress
        id
        sourceDate
        transactionId
        updatedAt
        vet360Id
      ]
    end

    it 'returns the expected email data', :aggregate_failures do
      email = results.dig('email')

      fields.each do |field|
        expect(email[field]).to be_present
      end
    end

    it 'returns no errors' do
      expect(response.dig('data', 'errors')).to be_nil
    end
  end

  context 'an address field' do
    let(:query) do
      <<-GRAPHQL
        query {
          userVet360ContactInformation {
            residentialAddress {
              addressLine1
              addressLine2
              addressLine3
              addressPou
              addressType
              city
              countryName
              countryCodeIso2
              countryCodeIso3
              countyCode
              countyName
              createdAt
              effectiveEndDate
              effectiveStartDate
              id
              internationalPostalCode
              sourceDate
              stateCode
              transactionId
              updatedAt
              vet360Id
              zipCode
              zipCodeSuffix
            }
            errors {
              type
              message
            }
          }
        }
      GRAPHQL
    end

    let(:response) { VetsAPISchema.execute(query, context: { current_user: user }) }
    let(:results) { response.dig('data', 'userVet360ContactInformation') }
    let(:fields) do
      %w[
        addressLine1
        addressPou
        addressType
        city
        countryName
        countryCodeIso3
        createdAt
        id
        sourceDate
        stateCode
        transactionId
        updatedAt
        vet360Id
        zipCode
      ]
    end

    it 'returns the expected address data', :aggregate_failures do
      residential_address = results.dig('residentialAddress')

      fields.each do |field|
        expect(residential_address[field]).to be_present
      end
    end

    it 'returns no errors' do
      expect(response.dig('data', 'errors')).to be_nil
    end
  end

  context 'a phone field' do
    let(:query) do
      <<-GRAPHQL
        query {
          userVet360ContactInformation {
            mobilePhone {
              areaCode
              countryCode
              createdAt
              extension
              id
              isInternational
              isVoicemailable
              phoneNumber
              phoneType
              sourceDate
              transactionId
              isTty
              updatedAt
              vet360Id
              effectiveEndDate
              effectiveStartDate
            }
            errors {
              type
              message
            }
          }
        }
      GRAPHQL
    end

    let(:response) { VetsAPISchema.execute(query, context: { current_user: user }) }
    let(:results) { response.dig('data', 'userVet360ContactInformation') }
    let(:fields) do
      %w[
        areaCode
        countryCode
        createdAt
        id
        isInternational
        isVoicemailable
        phoneNumber
        phoneType
        sourceDate
        transactionId
        isTty
        updatedAt
        vet360Id
      ]
    end

    it 'returns the expected phone data', :aggregate_failures do
      mobile_phone = results.dig('mobilePhone')

      fields.each do |field|
        expect(mobile_phone[field]).to_not be_nil
      end
    end

    it 'returns no errors' do
      expect(response.dig('data', 'errors')).to be_nil
    end
  end

  context 'with all Vet360 fields' do
    let(:query) do
      <<-GRAPHQL
        query {
          userVet360ContactInformation {
            email {
              emailAddress
            }
            residentialAddress {
              addressLine1
            }
            mailingAddress {
              addressLine1
            }
            mobilePhone {
              phoneNumber
            }
            homePhone {
              phoneNumber
            }
            workPhone {
              phoneNumber
            }
            temporaryPhone {
              phoneNumber
            }
            faxNumber {
              phoneNumber
            }
            errors {
              type
              message
            }
          }
        }
      GRAPHQL
    end

    let(:response) { VetsAPISchema.execute(query, context: { current_user: user }) }
    let(:results) { response.dig('data', 'userVet360ContactInformation') }
    let(:fields) do
      %w[
        email
        residentialAddress
        mailingAddress
        mobilePhone
        homePhone
        workPhone
        temporaryPhone
        faxNumber
      ]
    end

    it 'returns the expected Vet360 data', :aggregate_failures do
      fields.each do |field|
        expect(results[field]).to be_present
      end
    end

    it 'returns no errors' do
      expect(response.dig('data', 'errors')).to be_nil
    end
  end

  context 'with an error' do
    let(:query) do
      <<-GRAPHQL
        query {
          userVet360ContactInformation {
            email {
              emailAddress
            }
            errors {
              type
              message
            }
          }
        }
      GRAPHQL
    end

    before do
      allow(user).to receive(:vet360_contact_info).and_raise(StandardError, 'some error')
    end

    it 'returns error details', :aggregate_failures do
      response = VetsAPISchema.execute(query, context: { current_user: user })
      errors   = response.dig('data', 'userVet360ContactInformation', 'errors')

      expect(errors.dig('type')).to eq 'StandardError'
      expect(errors.dig('message')).to eq 'some error'
    end
  end
end
