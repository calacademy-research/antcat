module ApplicationHelper
  include LinkHelper

  def make_title title
    string = ''.html_safe
    string << "#{title} - " if title
    string << "AntCat"
    string << (Rails.env.production? ? '' : " (#{Rails.env})")
    string
  end

  def make_link_menu *items
    content_tag :span, class: 'link_menu' do |content|
      items.flatten.inject(''.html_safe) do |string, item|
        string << ' | '.html_safe unless string.empty?
        string << item
      end
    end
  end

  def rank_options_for_select value='All'
    string =  option_for_select('All', 'All', value)
    string << Rank.ranks.reject { |rank| rank.string == 'family'}.reduce("") do |options, rank|
              options << option_for_select(rank.plural.capitalize, rank.string.capitalize, value)
            end.html_safe
  end

  def biogeographic_region_options_for_select value='', first_label = '', second_label = nil
    string =  option_for_select(first_label, nil, value)
    string << option_for_select(second_label, second_label, value) if second_label.present?
    BiogeographicRegion.instances.each do |biogeographic_region|
      string << option_for_select(biogeographic_region.label, biogeographic_region.value, value)
      string
    end
    string
  end

  def search_selector search_type
    options = [['matching', 'm'],
               ['beginning with', 'bw'],
               ['containing', 'c']]
    select_tag :st, options_for_select(options, search_type || 'bw')
  end

  def pluralize_with_delimiters count, singular, plural = nil
    word = if count == 1
      singular
    else
      plural || singular.pluralize
    end
    "#{number_with_delimiter(count)} #{word}"
  end

  def count_and_noun collection, noun
    quantity = collection.present? ? collection.count.to_s : 'no'
    noun << 's' unless collection.count == 1
    "#{quantity} #{noun}"
  end

  def add_period_if_necessary string
    return unless string.present?
    return string + '.' unless string[-1..-1] =~ /[.!?]/
    string
  end

  def italicize string
    content_tag :i, string
  end

  def unitalicize string
    raise "Can't unitalicize an unsafe string" unless string.html_safe?
    string = string.dup
    string.gsub!('<i>', '')
    string.gsub!('</i>', '')
    string.html_safe
  end

  def embolden string
    content_tag :b, string
  end

  def format_time_ago time
    return unless time
    content_tag :span, "#{time_ago_in_words time} ago", title: time
  end

  # First attempt at creating a spinner that works on all elements.
  # Add .has-spinner to the button/link/element and call this method inside that element.
  # To be improved once all buttons are more consistently formatted site-wide.
  def spinner_icon
    "<span class='spinner'><i class='fa fa-refresh fa-spin'></i></span>".html_safe
  end

  # Used when more than one button can trigger the spinner.
  def shared_spinner_icon
    "<span class='shared-spinner'><i class='fa fa-refresh fa-spin'></i></span>".html_safe
  end

  # duplicated from ReferenceDecorator
  def format_italics string
    return unless string
    raise "Can't call format_italics on an unsafe string" unless string.html_safe?
    string = string.gsub /\*(.*?)\*/, '<i>\1</i>'
    string = string.gsub /\|(.*?)\|/, '<i>\1</i>'
    string.html_safe
  end

  def foundation_class_for flash_type
    case flash_type.to_sym
      when :success
        "primary"
      when :error
        "alert"
      when :alert
        "alert"
      when :warning
        "alert"
      when :notice
        "primary"
      else
        "secondary"
    end
  end

  private
    def option_for_select label, value, current_value
      options = { value: value }
      options[:selected] = 'selected' if value == current_value
      content_tag :option, label, options
    end
end
