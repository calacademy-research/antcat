class Exporters::Antweb::ExportHistoryItems
  include ERB::Util
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include ApplicationHelper

  def initialize taxon
    @taxon = taxon
  end

  def history
    return unless @taxon.history_items.present?

    history_content = content_tag :div, class: 'history' do
      @taxon.history_items.reduce(''.html_safe) do |content, item|
        content << history_item(item)
      end
    end

    '<p><b>Taxonomic history</b></p>'.html_safe + history_content
  end

  private
    def history_item item
      content_tag :div, class: "history_item" do
        content_tag :table do
          content_tag :tr do
            history_item_body item
          end
        end
      end
    end

    def history_item_body item
      content_tag :td, class: 'history_item_body', style: 'font-size: 13px' do
        add_period_if_necessary TaxtPresenter[item.taxt].to_antweb
      end
    end
end
