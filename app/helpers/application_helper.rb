# frozen_string_literal: true

module ApplicationHelper
  def or_dash thing
    return ndash if thing.blank? || thing.try(:zero?)
    thing
  end

  def ndash
    "–" # "&ndash;".
  end

  def mdash
    "—" # "&mdash;".
  end

  def add_period_if_necessary string
    AddPeriodIfNecessary[string]
  end

  def external_link_to label, url
    link_to label, url, class: 'external-link'
  end

  def pdf_link_to label, url
    link_to label, url, class: 'pdf-link', rel: 'nofollow'
  end

  def yes_no_options_for_select value
    options_for_select([["Yes", "true"], ["No", "false"]], value)
  end

  def per_page_select per_page_options, value
    options = per_page_options.map { |number| ["Show #{number} results per page", number] }
    select_tag :per_page, options_for_select(options, (value || 30))
  end

  def beta_label
    tag.span "beta", class: "rounded-badge"
  end

  def new_label
    tag.span "new!", class: "rounded-badge"
  end

  def flash_message_class flash_type
    case flash_type.to_sym
    when :notice then "primary"
    when :alert  then "alert"
    when :error  then "alert"
    else         raise "flash_type `#{flash_type}` not supported"
    end
  end

  def menu_active? menu
    last_breadcrumb = breadcrumbs.last&.key # HACK: Special case.
    return menu == :activity_feed if last_breadcrumb == :activity_feed

    first_breadcrumb = breadcrumbs.first&.key
    menu == first_breadcrumb
  end

  def submenu_css submenu
    if submenu_active? submenu
      'btn-nodanger'
    else
      'btn-normal'
    end
  end

  def submenu_active? submenu
    second_breadcrumb = breadcrumbs.second&.key
    submenu == second_breadcrumb
  end

  def inline_expandable label = "Show more", &block
    toggler_name = SecureRandom.uuid

    show_more = tag.a tag.small(label), class: "hide-when-expanded gray", data: { toggler_name: toggler_name }
    hidden = tag.span(class: "show-when-expanded hidden", data: { toggler_name: toggler_name }, &block)

    tag.span class: "expandable", data: { action: 'click->toggler#toggle', toggler_target: toggler_name } do
      show_more + hidden
    end
  end

  def edit_summary_text_field_tag optional: true
    placeholder = "Edit summary (#{optional ? 'optional' : 'required'})"

    text_field_tag :edit_summary, params[:edit_summary],
      placeholder: placeholder, maxlength: Activity::EDIT_SUMMARY_MAX_LENGTH
  end

  def current_page_redirect_back_url
    { redirect_back_url: request.fullpath }
  end

  def current_page_for_feedback
    request.original_fullpath.delete_prefix('/')
  end
end
