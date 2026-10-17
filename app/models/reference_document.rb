# frozen_string_literal: true

# TODO: Remove `url` and only allow uploading files on S3.

class ReferenceDocument < ApplicationRecord
  # Characters that Paperclip (6.1 defaults) replaced with "_" in uploaded file names before
  # `#transliterated_file_name` ran. Kept so that new file names look like old ones.
  RESTRICTED_FILE_NAME_CHARACTERS = %r{[&$+,/:;=?@<>\[\]{}|\\^~%# ]}

  # Legacy source URLs must be plain web links.
  HTTP_URL_REGEX = %r{\Ahttps?://[^\s<>"]+\z}i

  belongs_to :reference

  validates :url, absence: true, on: :create
  validates :url, format: { with: HTTP_URL_REGEX, message: "must start with http:// or https://" }, allow_blank: true
  validate :ensure_file_or_url_present

  after_save :upload_file

  has_paper_trail
  strip_attributes only: [:url]

  def self.http_url? value
    value.is_a?(String) && HTTP_URL_REGEX.match?(value)
  end

  # Data check (report only): legacy documents whose `url` is not a plain http(s) link.
  # See `rake antcat:references:documents_with_non_http_urls`.
  def self.with_non_http_url
    where.not(url: [nil, '']).order(:id).reject { |document| http_url?(document.url) }
  end

  # The uploaded file waiting to be stored on S3 (`nil` unless a file was assigned).
  attr_reader :file

  # Accepts an uploaded file (`ActionDispatch::Http::UploadedFile`, `Rack::Test::UploadedFile` or `File`).
  # Blank values (an empty file field) are ignored. Old files on S3 are never deleted.
  def file= new_file
    return if new_file.blank?

    @file = new_file
    self.file_file_name = transliterated_file_name(original_file_name_of(new_file))
    file_file_name_will_change! # Make sure that re-uploading a file with the same name is saved and uploaded.
  end

  # Legacy URLs that are not http(s) (existing data from before the validation) are never returned.
  def actual_url
    hosted_on_s3? ? References::DocumentStorage.presigned_url(s3_key) : http_url
  end

  def routed_url
    hosted_on_s3? ? url_via_file_file_name : http_url
  end

  private

    def original_file_name_of new_file
      name = new_file.respond_to?(:original_filename) ? new_file.original_filename : nil
      name ||= File.basename(new_file.path)
      name.gsub(RESTRICTED_FILE_NAME_CHARACTERS, '_')
    end

    def transliterated_file_name file_name
      extension = File.extname(file_name).gsub(/^\.+/, '')
      filename = file_name.gsub(/\.#{extension}$/, '')
      "#{ActiveSupport::Inflector.parameterize(filename)}.#{ActiveSupport::Inflector.parameterize(extension)}"
    end

    def upload_file
      return unless file

      References::DocumentStorage.upload(key: s3_key, path: file.path, content_type: content_type_of(file))
      @file = nil
    end

    def content_type_of uploaded_file
      Marcel::MimeType.for(Pathname.new(uploaded_file.path), name: file_file_name)
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

    def http_url
      url if self.class.http_url?(url)
    end

    def s3_key
      "#{id}/#{file_file_name}"
    end

    def url_via_file_file_name
      "#{Settings.site_url}/documents/#{id}/#{file_file_name}"
    end
end
