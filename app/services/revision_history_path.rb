class RevisionHistoryPath
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include Service

  def initialize type, id
    @type = type
    @id = id
  end

  def call
    url
  end

  private
    attr_reader :type, :id

    def url
      case type
      when "Reference"        then reference_history_index_path id
      when "TaxonHistoryItem" then taxon_history_item_path id
      when "ReferenceSection" then reference_section_path id
      when "Taxon"            then taxon_history_path id
      when "Tooltip"          then tooltip_history_index_path id
      end
    end
end
