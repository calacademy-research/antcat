# frozen_string_literal: true

# TODO: Remove `url` and only allow uploading files on S3.
# TODO: Paperclip has been deprecated, see https://github.com/thoughtbot/paperclip

class ReferenceDocument < ApplicationRecord
  belongs_to :reference

  validates :url, absence: true, on: :create
  validate :ensure_file_or_url_present

  has_attached_file :file,
    preserve_files: true,
    url: ':s3_domain_url',
    path: ':id/:filename',
    bucket: Settings.s3.bucket,
    storage: :s3,
    s3_credentials: {
      access_key_id: Settings.s3.access_key_id,
      secret_access_key: Settings.s3.secret_access_key
    },
    s3_permissions: 'authenticated-read',
    s3_region: Settings.s3.region,
    s3_protocol: 'http'
  before_post_process :transliterate_file_name
  do_not_validate_attachment_file_type :pdf
  has_paper_trail
  strip_attributes only: [:url]

  def pdf
    true
  end

  def actual_url
    hosted_on_s3? ? s3_url : url
  end

  def routed_url
    hosted_on_s3? ? url_via_file_file_name : url
  end

  private

    def transliterate_file_name
      file.instance_write(:file_name, transliterated_file_name)
    end

    def transliterated_file_name
      extension = File.extname(file_file_name).gsub(/^\.+/, '')
      filename = file_file_name.gsub(/\.#{extension}$/, '')
      "#{ActiveSupport::Inflector.parameterize(filename)}.#{ActiveSupport::Inflector.parameterize(extension)}"
    end

    def ensure_file_or_url_present
      if file_file_name.present? && url.present?
        errors.add :base, "URL and uploaded file cannot both be present"
      end

      if file_file_name.blank? && url.blank?
        errors.add :base, "URL and uploaded file cannot both be blank"
      end
    end

    def hosted_on_s3?
      file_file_name.present?
    end

    def url_via_file_file_name
      "https://antcat.org/documents/#{id}/#{file_file_name}"
    end

    def s3_url
      file.expiring_url 1.day.seconds.to_i
    end
end
