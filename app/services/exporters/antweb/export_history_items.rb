class Exporters::Antweb::ExportHistoryItems
  include ActionView::Helpers::TagHelper # For `#content_tag`.
  include ActionView::Context # For `#content_tag`.
  include ApplicationHelper
  include Service

  def initialize taxon
    @taxon = taxon
  end

  def call
    return if taxon.history_items.blank?

    history_content = content_tag :div do
      taxon.history_items.reduce(''.html_safe) do |content, item|
        content << history_item(item)
      end
    end

    '<p><b>Taxonomic history</b></p>'.html_safe + history_content
  end

  private

    attr_reader :taxon

    def history_item item
      content_tag :div do
        content_tag :table do
          content_tag :tr do
            history_item_body item
          end
        end
      end
    end

    def history_item_body item
      content_tag :td do
        add_period_if_necessary TaxtPresenter[item.taxt].to_antweb
      end
    end
end
