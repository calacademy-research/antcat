# frozen_string_literal: true

module TooltipHelper
  def db_tooltip_icon key, scope:
    tooltip = Tooltip.find_by(key: key, scope: scope)
    return new_db_tooltip(key, scope) unless tooltip
    link_to tooltip_icon(tooltip.text), tooltip
  end

  def tooltip_icon text
    content_tag :span, antcat_icon("tooltip-icon"), title: brs_to_new_lines(text), class: "tooltip2"
  end

  def info_tooltip_icon text
    content_tag :span, antcat_icon("info-tooltip"), title: brs_to_new_lines(text), class: "tooltip2"
  end

  # For content that which it is not obvious it is hidden to logged-out visitors.
  def logged_in_only_tooltip_icon text = nil, user_group: 'logged-in users'
    title = brs_to_new_lines(text || "This section is only visible to #{user_group}")
    content_tag :span, antcat_icon("info-tooltip"), title: title, class: "tooltip2"
  end

  private

    def new_db_tooltip key, scope
      text = "Could not find tooltip with key '#{key}' with page scope '#{scope}'. Click icon to create."
      link_to tooltip_icon(text), new_tooltip_path(key: key, scope: scope)
    end

    # https://stackoverflow.com/questions/3340802/add-line-break-within-tooltips
    def brs_to_new_lines text
      sanitize text.gsub(%r{<br ?/?>}, '&#013;&#010;')
    end
end
