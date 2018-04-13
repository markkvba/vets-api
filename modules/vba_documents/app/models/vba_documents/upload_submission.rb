module VBADocuments
  class UploadSubmission < ActiveRecord::Base
    include SetGuid

    # TODO: Persist this? Otherwise it regenerates with new expiry
    # every time object is serialized
    def get_location
      rewrite_url(signed_url(guid))
    end

    private

    def rewrite_url(url)
      # TODO remove puts
      puts url
      rewritten = url.sub!(Settings.documents.location.prefix, Settings.documents.location.replacement)
      raise 'Unable to provide document upload location' unless rewritten
      rewritten
    end

    def signed_url(guid)
      s3 = Aws::S3::Resource.new(region: Settings.documents.s3.region,
                                 access_key_id: Settings.documents.s3.aws_access_key_id,
                                 secret_access_key: Settings.documents.s3.aws_secret_access_key)
      obj = s3.bucket(Settings.documents.s3.bucket).object(guid)
      obj.presigned_url(:put, {})
    end
  end
end
