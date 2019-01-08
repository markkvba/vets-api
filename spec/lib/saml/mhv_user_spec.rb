# frozen_string_literal: true

require 'rails_helper'
require 'support/saml/response_builder'

RSpec.describe SAML::User do
  describe 'MHV Logon' do
    let(:saml_response) do
      SAML::ResponseBuilder.saml_response_from_attributes('myhealthevet', saml_attributes)
    end
    let(:described_instance) { described_class.new(saml_response) }

    context 'non-premium user' do
      let(:saml_attributes) do
        OneLogin::RubySaml::Attributes.new(
          'mhv_icn' => ['1012853550V207686'],
          'mhv_profile' => ['{"accountType":"Advanced","availableServices":{"1":"Blue Button self entered data."}}'],
          'mhv_uuid' => ['12345748'],
          'email' => ['kam+tristanmhv@adhocteam.us'],
          'multifactor' => ['true'],
          'uuid' => ['0e1bb5723d7c4f0686f46ca4505642ad'],
          'level_of_assurance' => []
        )
      end

      it 'has various important attributes' do
        expect(described_instance.to_hash).to eq(
          uuid: '0e1bb5723d7c4f0686f46ca4505642ad',
          email: 'kam+tristanmhv@adhocteam.us',
          loa: { current: 1, highest: 1 },
          mhv_account_type: 'Advanced',
          mhv_correlation_id: '12345748',
          mhv_icn: '1012853550V207686',
          multifactor: 'true',
          authn_context: 'myhealthevet'
        )
      end

      it 'is not changing multifactor' do
        expect(described_instance.changing_multifactor?).to be_falsey
      end

      context 'multifactor' do
        let(:saml_response) do
          SAML::ResponseBuilder.saml_response_from_attributes('myhealthevet_multifactor', saml_attributes)
        end

        it 'is changing multifactor' do
          expect(described_instance.changing_multifactor?).to be_truthy
        end

        it 'has a account_type' do
          expect(described_instance.account_type).to eq('Advanced')
        end
      end
    end

    context 'premium user' do
      let(:saml_attributes) do
        OneLogin::RubySaml::Attributes.new(
          'mhv_icn' => ['1012853550V207686'],
          # rubocop:disable LineLength
          'mhv_profile' => ['{"accountType":"Premium","availableServices":{"21":"VA Medications","4":"Secure Messaging","3":"VA Allergies","2":"Rx Refill","12":"Blue Button (all VA data)","1":"Blue Button self entered data.","11":"Blue Button (DoD) Military Service Information"}}'],
          # rubocop:enable LineLength
          'mhv_uuid' => ['12345748'],
          'email' => ['kam+tristanmhv@adhocteam.us'],
          'multifactor' => ['false'],
          'uuid' => ['0e1bb5723d7c4f0686f46ca4505642ad'],
          'level_of_assurance' => []
        )
      end

      it 'has various important attributes' do
        expect(described_instance.to_hash).to eq(
          uuid: '0e1bb5723d7c4f0686f46ca4505642ad',
          email: 'kam+tristanmhv@adhocteam.us',
          loa: { current: 3, highest: 3 },
          mhv_account_type: 'Premium',
          mhv_correlation_id: '12345748',
          mhv_icn: '1012853550V207686',
          multifactor: 'false',
          authn_context: 'myhealthevet'
        )
      end

      it 'has a account_type' do
        expect(described_instance.account_type).to eq('Premium')
      end

      it 'is not changing multifactor' do
        expect(described_instance.changing_multifactor?).to be_falsey
      end

      context 'multifactor' do
        let(:saml_response) do
          SAML::ResponseBuilder.saml_response_from_attributes('myhealthevet_multifactor', saml_attributes)
        end

        it 'is changing multifactor' do
          expect(described_instance.changing_multifactor?).to be_truthy
        end
      end
    end
  end
end
