# frozen_string_literal: true

# Stores uploaded `ReferenceDocument` files on S3. Replaces Paperclip, using the same bucket,
# key layout ("<reference_document.id>/<file_file_name>") and ACL, so existing objects keep working.
module References
  class DocumentStorage
    class NotConfigured < StandardError; end

    ACL = 'authenticated-read'
    URL_EXPIRES_IN = 1.day.to_i

    class << self
      def upload key:, path:, content_type:
        File.open(path, 'rb') do |io|
          client.put_object(bucket: bucket, key: key, body: io, acl: ACL, content_type: content_type)
        end
      end

      def presigned_url key
        Aws::S3::Presigner.new(client: client).
          presigned_url(:get_object, bucket: bucket, key: key, expires_in: URL_EXPIRES_IN)
      end

      # Built on first use, so pages render on servers without S3 credentials (only document links fail).
      def client
        @_client ||= begin
          raise NotConfigured, "S3 settings (Settings.s3) are incomplete" unless configured?

          Aws::S3::Client.new(
            region: Settings.s3.region,
            credentials: Aws::Credentials.new(Settings.s3.access_key_id, Settings.s3.secret_access_key)
          )
        end
      end

      def reset_client!
        @_client = nil
      end

      def configured?
        s3_settings = Settings.s3
        return false if s3_settings.blank?
        [:access_key_id, :secret_access_key, :bucket, :region].all? { |setting| s3_settings[setting].present? }
      end

      private

        def bucket
          Settings.s3.bucket
        end
    end
  end
end
