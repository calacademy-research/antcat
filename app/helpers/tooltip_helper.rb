# TODO: This is for jQuery tooltips. Rename to avoid confusing with Foundation's tooltips.

module TooltipHelper
  def enable_tooltips
    content_for(:javascripts) { javascript_include_tag "tooltips" }
  end

  def db_tooltip_icon key, scope:
    tooltip = Tooltip.find_by(key: key, scope: scope)

    return new_db_tooltip(key, scope) unless tooltip
    link_to tooltip_icon(tooltip.text), tooltip
  end

  def tooltip_icon text
    content_tag :span, nil, title: sanitize(text), class: "antcat_icon tooltip-icon jquery-tooltip"
  end

  def info_tooltip_icon text
    content_tag :span, nil, title: sanitize(text), class: "antcat_icon info-tooltip jquery-tooltip"
  end

  # For content that which it is not obvious it is for logged-in users only.
  def logged_in_only_tooltip_icon text = nil
    content_tag :span, nil, title: (text || 'This section is only visible to logged-in users'),
      class: "antcat_icon logged-in-only-icon jquery-tooltip"
  end

  private

    def new_db_tooltip key, scope
      text = "Could not find tooltip with key '#{key}' with page scope '#{scope}'. Click icon to create."
      link_to tooltip_icon(text), new_tooltip_path(key: key, scope: scope)
    end
end
