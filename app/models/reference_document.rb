# frozen_string_literal: true

# TODO: Remove `url` and only allow uploading files on S3.

class ReferenceDocument < ApplicationRecord
  # Characters that Paperclip (6.1 defaults) replaced with "_" in uploaded file names before
  # `#transliterated_file_name` ran. Kept so that new file names look like old ones.
  RESTRICTED_FILE_NAME_CHARACTERS = %r{[&$+,/:;=?@<>\[\]{}|\\^~%# ]}

  belongs_to :reference

  validates :url, absence: true, on: :create
  validate :ensure_file_or_url_present

  after_save :upload_file

  has_paper_trail
  strip_attributes only: [:url]

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

  def actual_url
    hosted_on_s3? ? References::DocumentStorage.presigned_url(s3_key) : url
  end

  def routed_url
    hosted_on_s3? ? url_via_file_file_name : url
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

    def s3_key
      "#{id}/#{file_file_name}"
    end

    def url_via_file_file_name
      "#{Settings.site_url}/documents/#{id}/#{file_file_name}"
    end
end
