class TaxonDecorator::History
  include ERB::Util
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  include ApplicationHelper

  include RefactorHelper
  include AntwebRefactorHelper if $use_ant_web_formatter

  def initialize taxon, user=nil
    @taxon = taxon
    @user = user
  end

  def history
    if @taxon.history_items.present?
      content = content_tag :div, class: 'history' do
        @taxon.history_items.inject(''.html_safe) do |content, item|
          content << history_item(item)
        end
      end
      if $use_ant_web_formatter
        return '<p><b>Taxonomic history</b></p>'.html_safe + content
      else
        return content
      end
    end
  end

  private
    def history_item item
      css_class = "history_item item_#{item.id}"
      content_tag :div, class: css_class, 'data-id' => item.id do
        content_tag :table do
          content_tag :tr do
            history_item_body item
          end
        end
      end
    end

    def history_item_body_attributes
      if $use_ant_web_formatter
        { style: 'font-size: 13px' }
      else
        {}
      end
    end

    def history_item_body item
      content_tag :td, history_item_body_attributes.merge(class: 'history_item_body') do
        add_period_if_necessary detaxt item.taxt
      end
    end

    def detaxt taxt #for AntWeb exporter
      return '' unless taxt.present?
      Taxt.to_string taxt, @user, expansion: false, formatter: Exporters::Antweb::Formatter
    end

end
