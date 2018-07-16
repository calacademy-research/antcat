module ApplicationHelper
  include LinkHelper

  def or_dash thing
    return dash if thing.blank? || thing.try(:zero?)
    thing
  end

  def dash
    "&ndash;".html_safe
  end

  def pluralize_with_delimiters count, singular, plural = nil
    word = if count == 1
             singular
           else
             plural || singular.pluralize
           end
    "#{number_with_delimiter(count)} #{word}"
  end

  def add_period_if_necessary string
    return "".html_safe unless string.present?
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

  def beta_label
    content_tag :span, "beta", class: "label"
  end

  def new_label
    content_tag :span, "new!", class: "label"
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

  def foundation_class_for flash_type
    case flash_type.to_sym
    when :success, :notice        then "primary"
    when :error, :alert, :warning then "alert"
    else                               "secondary"
    end
  end

  def inline_expandable label = "Show more"
    show_more = content_tag :a, class: "hide-when-expanded gray" do
                  content_tag :small, label
                end
    hidden = content_tag :span, class: "show-when-expanded" do
               yield
             end

    content_tag :span, class: "expandable" do
      show_more + hidden
    end
  end

  def antcat_icon *css_classes
    content_tag :span, nil,
      class: ["antcat_icon"].concat(Array.wrap css_classes)
  end
end
