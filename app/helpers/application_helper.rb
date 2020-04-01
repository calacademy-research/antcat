# frozen_string_literal: true

module ApplicationHelper
  def or_dash thing
    return dash if thing.blank? || thing.try(:zero?)
    thing
  end

  def dash
    "&ndash;".html_safe
  end

  def add_period_if_necessary string
    AddPeriodIfNecessary[string]
  end

  # TODO: See if we can use CSS only instead.
  def external_link_to label, url
    link_to label, url, class: 'external-link'
  end

  # TODO: See if we can use CSS only instead.
  def pdf_link_to label, url
    link_to label, url, class: 'pdf-link'
  end

  def yes_no_options_for_select value
    options_for_select([["Yes", "true"], ["No", "false"]], value)
  end

  def per_page_select per_page_options, value
    options = per_page_options.map { |number| ["Show #{number} results per page", number] }
    select_tag :per_page, options_for_select(options, (value || 30))
  end

  def beta_label
    content_tag :span, "beta", class: "rounded-badge"
  end

  def new_label
    content_tag :span, "new!", class: "rounded-badge"
  end

  def foundation_class_for flash_type
    case flash_type.to_sym
    when :notice then "primary"
    when :alert  then "alert"
    when :error  then "alert"
    else         raise "flash_type `#{flash_type}` not supported"
    end
  end

  def menu_active? menu
    last_breadcrumb = breadcrumbs.last&.key # TODO: Special case.
    return menu == :activity_feed if last_breadcrumb == :activity_feed

    first_breadcrumb = breadcrumbs.first&.key
    menu == first_breadcrumb
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

  def edit_summary_text_field_tag
    text_field_tag :edit_summary, params[:edit_summary], placeholder: "Edit summary (optional)", maxlength: Activity::EDIT_SUMMARY_MAX_LENGTH
  end

  def current_page_for_feedback
    request.original_fullpath.gsub(%r{^/}, "")
  end
end
