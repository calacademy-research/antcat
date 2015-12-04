# coding: UTF-8
class Formatters::TaxonFormatter
  include ActionView::Helpers::TagHelper
  extend ActionView::Helpers::TagHelper
  include ActionView::Context
  include Formatters::Formatter
  extend Formatters::Formatter
  include Formatters::LinkFormatter
  extend Formatters::LinkFormatter

  def initialize taxon, user = nil
    @taxon, @user = taxon, user
  end

  def statistics options = {}
    @taxon.decorate.statistics options
  end

  def genus_species_header_notes_taxt
    @taxon.decorate.genus_species_header_notes_taxt
  end

  def headline
    @taxon.decorate.headline
  end

  def history
    @taxon.decorate.history
  end

  def child_lists
    @taxon.decorate.child_lists
  end

  def references
    @taxon.decorate.references
  end

  public def history
    if @taxon.history_items.present?
      content_tag :div, class: 'history' do
        @taxon.history_items.inject(''.html_safe) do |content, item|
          content << history_item(item)
        end
      end
    end
  end

  private def history_item item
    css_class = "history_item item_#{item.id}"
    content_tag :div, class: css_class, 'data-id' => item.id do
      content_tag :table do
        content_tag :tr do
          history_item_body item
        end
      end
    end
  end

  private def history_item_body_attributes
    {}
  end

  private def history_item_body item
    content_tag :td, history_item_body_attributes.merge(class: 'history_item_body') do
      add_period_if_necessary detaxt item.taxt
    end
  end

end