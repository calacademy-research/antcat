module Taxa::CallbacksAndValidators
  extend ActiveSupport::Concern

  included do
    validates :name, presence: true
    validates :protonym, presence: true
    validates :biogeographic_region,
      inclusion: { in: BiogeographicRegion::REGIONS, allow_nil: true }
    validate :check_url

    before_validation :add_protocol_to_type_speciment_url
    before_validation :nilify_biogeographic_region_if_blank
    before_save { CleanNewlines.clean_newlines self, :headline_notes_taxt, :type_taxt }
    before_save :set_name_caches, :delete_synonyms
  end

  private
    def nilify_biogeographic_region_if_blank
      self.biogeographic_region = nil if biogeographic_region.blank?
    end

    def set_name_caches
      self.name_cache = name.name
      self.name_html_cache = name.name_html
    end

    def delete_synonyms
      return unless changes['status'].try(:first) == 'synonym'
      synonyms_as_junior.destroy_all if synonyms_as_junior.present?
    end

    def add_protocol_to_type_speciment_url
      return if type_specimen_url.blank? || type_specimen_url =~ %r{^https?://}
      self.type_specimen_url = "http://#{type_specimen_url}"
    end

    def check_url
      return if type_specimen_url.blank?
      # a URL with spaces is valid, but URI.parse rejects it
      uri = URI.parse type_specimen_url.gsub(/ /, '%20')
      response_code = Net::HTTP.new(uri.host, 80).request_head(uri.request_uri).code.to_i
      errors.add :type_specimen_url, 'was not found' unless (200..399).include? response_code
    rescue SocketError, URI::InvalidURIError, ArgumentError
      errors.add :type_specimen_url, 'is not in a valid format'
    end
end
