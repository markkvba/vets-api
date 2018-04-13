# frozen_string_literal: true

module VBADocuments
  class UploadScanner
    include Sidekiq::Worker

    def perform
      VBADocuments::UploadSubmission.where(status: 'pending').find_each do |upload|
        # TODO expire records after upload URL is obsolete (default 900 secs)
        process(upload)  
      end
    end

    private

    def process(upload)
      Rails.logger.info("Processing: " + upload.inspect)
      Rails.logger.info("Upload exists: " + bucket.object(upload.guid).exists?.to_s)
      return false unless bucket.object(upload.guid).exists?
      VBADocuments::UploadProcessor.perform_async(upload.guid)
      upload.update(status: 'uploaded')
      return true
    end

    def bucket
      @bucket ||= begin
        s3 = Aws::S3::Resource.new(region: Settings.documents.s3.region,
                                   access_key_id: Settings.documents.s3.aws_access_key_id,
                                   secret_access_key: Settings.documents.s3.aws_secret_access_key)
        bucket = s3.bucket(Settings.documents.s3.bucket)
      end
    end
  end
end
