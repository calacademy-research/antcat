class Document < ActiveRecord::Base
  has_attached_file :file,
                    :url => ':s3_domain_url',
                    :path => ':attachment/:id/:filename',
                    :bucket => 'antcat',
                    :storage => :s3,
                    :s3_credentials => Rails.root + 'config' + 's3.yml',
                    :s3_permissions => 'authenticated-read',
                    :s3_protocol => 'http'

  before_validation :set_url

  def set_uploaded_url host
    update_attribute :url, "http://#{host}/files/#{id}/#{file_file_name}"
  end

  def set_url
    self.url = "http://" + url if url.present? && url !~ %r{^http://}
  end

  def hosted_by_us?
    file_file_name.present?
  end

  def authenticated_url
    AWS::S3::S3Object.url_for(file.path, file.bucket_name, :expires_in => 1)
  end

  def validate
    return if file_file_name.present? or url.blank?
    uri = URI.parse url
    response_code = Net::HTTP.new(uri.host, 80).request_head(uri.path).code.to_i
    errors.add :url, 'was not found' unless (200..399).include? response_code
  rescue URI::InvalidURIError, ArgumentError
    errors.add :url, 'is not in a valid format'
  end

end
