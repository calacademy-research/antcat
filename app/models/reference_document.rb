class ReferenceDocument < ActiveRecord::Base
  has_attached_file :file,
                    :url => ':s3_domain_url',
                    :path => ':id/:filename',
                    :bucket => 'antcat',
                    :storage => :s3,
                    :s3_credentials => (Rails.env.production? ? '/data/antcat/shared/config/' : Rails.root + 'config/') + 's3.yml',
                    :s3_permissions => 'authenticated-read',
                    :s3_protocol => 'http'

  before_validation :add_protocol_to_url
  belongs_to :reference
  validate :check_url

  def host= host
    return unless hosted_by_us?
    update_attribute :url, "http://#{host}/documents/#{id}/#{file_file_name}"
  end

  def downloadable_by? user
    url.present? && (attributes["public"] || !hosted_by_us? || user.present?)
  end

  def actual_url
    hosted_by_us? ? s3_url : url
  end

  private
  def check_url
    return if file_file_name.present? or url.blank?
    uri = URI.parse url
    response_code = Net::HTTP.new(uri.host, 80).request_head(uri.path).code.to_i
    errors.add :url, 'was not found' unless (200..399).include? response_code
  rescue SocketError, URI::InvalidURIError, ArgumentError
    errors.add :url, 'is not in a valid format'
  end

  def hosted_by_us?
    file_file_name.present?
  end

  def add_protocol_to_url
    self.url = "http://" + url if url.present? && url !~ %r{^http://}
  end

  def s3_url
    AWS::S3::S3Object.url_for file.path, file.bucket_name, :expires_in => 10
  end

end
