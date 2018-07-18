# frozen_string_literal: true

require 'rails_helper'

describe VIC::Service, type: :model do
  let(:parsed_form) { JSON.parse(create(:vic_submission).form) }
  let(:service) { described_class.new }
  let(:user) { build(:evss_user) }
  let(:client) { double }
  let(:case_id) { 'case_id' }

  describe '#get_oauth_token' do
    it 'should get the access token from the request', run_at: '2018-02-06 21:51:48 -0500' do
      oauth_params = get_fixture('vic/oauth_params').symbolize_keys
      return_val = OpenStruct.new(body: { 'access_token' => 'token' })
      expect(service).to receive(:request).with(:post, '', oauth_params).and_return(return_val)

      expect(service.get_oauth_token).to eq('token')
    end
  end

  describe '#add_user_data!' do
    let(:converted_form) do
      { 'profile_data' => {} }
    end

    it 'should add user data to the request form' do
      expect(user.veteran_status).to receive(:title38_status).and_return('V1')
      service.add_user_data!(converted_form, user)
      expect(converted_form).to eq(
        'profile_data' => {
          'sec_ID' => '0001234567',
          'active_ICN' => user.icn,
          'SSN' => user.ssn,
          'historical_ICN' => %w[1000123457V123456 1000123458V123456]
        },
        'veteran_full_name' => { 'first' => 'Wesley', 'last' => 'Ford' },
        'title38_status' => 'V1'
      )
    end

    context 'when the veteran is not found' do
      it 'should omit the title 38 status' do
        expect(user.veteran_status).to receive(:title38_status).and_raise(EMISRedis::VeteranStatus::RecordNotFound)

        service.add_user_data!(converted_form, user)
        expect(converted_form).to eq(
          'profile_data' => {
            'sec_ID' => '0001234567',
            'active_ICN' => user.icn,
            'SSN' => user.ssn,
            'historical_ICN' => %w[1000123457V123456 1000123458V123456]
          },
          'veteran_full_name' => { 'first' => 'Wesley', 'last' => 'Ford' }
        )
      end
    end
  end

  describe '#convert_form' do
    it 'should format the form' do
      parsed_form['foo'] = 'bar'
      expect(service.convert_form(parsed_form)).to eq(
        'service_branch' => 'Air Force',
        'email' => 'foo@foo.com',
        'veteran_full_name' => { 'first' => 'Mark', 'last' => 'Olson' },
        'veteran_address' => {
          'city' => 'Milwaukee',
          'country' => 'US', 'postal_code' => '53130',
          'state' => 'WI', 'street' => '123 Main St', 'street2' => ''
        },
        'phone' => '5551110000',
        'profile_data' => { 'SSN' => '111223333', 'historical_ICN' => [] }
      )
    end
  end

  describe '#all_files_processed?' do
    it 'should see if the files are processed yet' do
      expect(service.all_files_processed?(parsed_form)).to eq(false)
      ProcessFileJob.drain
      expect(service.all_files_processed?(parsed_form)).to eq(true)
    end
  end

  describe '#combine_files' do
    context 'with no records' do
      it 'should return nil' do
        expect(service.combine_files([])).to eq(nil)
      end
    end

    context 'with one record' do
      it 'should convert the file' do
        records = [
          create(:supporting_documentation_attachment)
        ]
        ProcessFileJob.drain
        final_pdf = service.combine_files(records)

        expect(PDF::Reader.new(final_pdf).pages.size).to eq(1)

        File.delete(final_pdf)
      end
    end

    context 'with multiple records' do
      it 'should convert files to pdf and combine them' do
        records = [
          create(:supporting_documentation_attachment),
          create(:supporting_documentation_attachment)
        ]
        ProcessFileJob.drain
        final_pdf = service.combine_files(records)

        expect(PDF::Reader.new(final_pdf).pages.size).to eq(2)

        File.delete(final_pdf)
      end
    end
  end

  describe '#send_files' do
    it 'should send the files in the form' do
      parsed_form
      ProcessFileJob.drain
      expect(service).to receive(:get_client).and_return(client)
      expect(service).to receive(:combine_files).with(
        [VIC::SupportingDocumentationAttachment.last]
      ).and_return('combined.pdf')
      expect(service).to receive(:send_file_with_path).with(
        client,
        case_id,
        'combined.pdf',
        'application/pdf',
        'Discharge Documentation'
      )
      expect(service).to receive(:send_file).with(
        client, case_id,
        VIC::ProfilePhotoAttachment.last,
        'Photo'
      )
      service.send_files(case_id, parsed_form)
    end
  end

  describe '#send_file' do
    let(:attachment) do
      attachment = create(:supporting_documentation_attachment)
      ProcessFileJob.drain
      attachment
    end

    before do
      upload_io = double
      hex = '3e37ec951a66e3c6b6a58ae5c791bb9d'
      allow(SecureRandom).to receive(:hex).and_return(hex)
      allow(Restforce::UploadIO).to receive(:new).with(
        "tmp/#{hex}", 'application/pdf'
      ).and_return(upload_io)

      expect(client).to receive(:create!).with(
        'ContentVersion',
        Title: 'description', PathOnClient: 'description.pdf',
        VersionData: upload_io
      ).and_return('content_version_id')

      expect(client).to receive(:find).with(
        'ContentVersion',
        'content_version_id'
      ).and_return('ContentDocumentId' => 'document_id')

      expect(client).to receive(:create!).with(
        'ContentDocumentLink',
        ContentDocumentId: 'document_id',
        ShareType: 'V',
        LinkedEntityId: case_id
      )
    end

    def call_send_file
      service.send_file(client, case_id, attachment, 'description')
    end

    context 'with a successful upload' do
      it 'should read the mime type and send the file' do
        call_send_file

        expect(model_exists?(attachment)).to eq(false)
      end
    end
  end

  it 'f' do
    client = VIC::Service.new.get_client
    form = {
      "on_behalf_of": "Myself",
      "service_branch": "Army",
      "service_affiliation": "Spouse or Family Member",
      "entered_duty":"2000-01-01",
      "release_from_duty":"2000-01-01",
      "dob":"2000-01-01",
      "full_name": {
        "prefix": "Mr.",
        "first": "Test",
        "middle": "middle",
        "last": "User",
        "suffix": "Jr."
      },
      "address": {
        "street": "123 Main St",
        "street2": "apt 1",
        "city": "Milwaukee",
        "postal_code": "53130",
        "state": "WI",
        "country": "US"
      },
      "profile_data": {
        "active_ICN":"1234567890",
        "historical_ICN": [
          "7598562344",
          "999999999"
        ],
        "sec_ID":"dn49hd743hnf07423hr",
        "SSN":"123-45-6789"
      },
      "education_details": {
        "school": {
          "name":"Test University",
          "address": {
            "street": "123 Maple St",
            "street2": "apt 1",
            "city": "Milwaukee",
            "postal_code": "53130",
            "state": "WI",
            "country": "US"
          }
        },
        "programs": [
          "Post-9/11 GI Bill (Ch. 33)",
          "Survivors & Dependents Assitance (DEA) (Ch. 35)"
        ],
        "assistance": [
          "Federal Tuition Assistance (TA)",
          "Federal Financial Aid"
        ]
      },
      "issue": [
        "student_loans",
        "credit_transfer",
        "financial_issues"
      ],
      "issue_description": "Test issue description",
      "issue_resolution": "Test issue resolution",
      "phone": "5555555555",
      "email":"foo@foo.com"
    }
    binding.pry; fail
    client.post('/services/apexrest/educationcomplaint', form)
  end

  describe '#submit' do
    before do
      expect(service).to receive(:convert_form).with(parsed_form).and_return({})
      expect(service).to receive(:get_oauth_token).and_return('token')

      expect(Restforce).to receive(:new).with(
        oauth_token: 'token',
        instance_url: VIC::Configuration::SALESFORCE_INSTANCE_URL,
        api_version: '41.0'
      ).and_return(client)
      expect(client).to receive(:post).with(
        '/services/apexrest/VICRequest', {}
      ).and_return(
        OpenStruct.new(
          body: {
            'case_id' => 'case_id',
            'case_number' => 'case_number'
          }
        )
      )
    end

    def test_case_id(user)
      parsed_form
      ProcessFileJob.drain
      expect(service.submit(parsed_form, user)).to eq(case_id: 'case_id', case_number: 'case_number')
    end

    context 'with a user' do
      it 'should submit the form and attached documents' do
        expect(service).to receive(:add_user_data!).with({}, user)
        test_case_id(user)
      end
    end

    context 'with no user' do
      it 'should submit the form' do
        test_case_id(nil)
      end
    end
  end
end
