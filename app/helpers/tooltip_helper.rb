# TODO: This is for jQuery tooltips. Rename to avoid confusing with Foundation's tooltips.

module TooltipHelper
  def enable_tooltips
    content_for(:head) { javascript_include_tag "tooltips" }
  end

  def tooltip_icon key_param, scope: nil
    tooltip = Tooltip.find_by(key: key_param, scope: scope)

    return new_populated_tooltip(key_param, scope) unless tooltip
    return unless tooltip.key_enabled?

    link_to tooltip_help_icon(tooltip.text), tooltip
  end

  def tooltip_help_icon text
    content_tag :span, nil, class: "antcat_icon tooltip-icon jquery-tooltip", title: sanitize(text)
  end

  private

    def new_populated_tooltip key, scope
      text = "Could not find tooltip with key '#{key}' with page scope '#{scope}'. Click icon to create."
      link_to tooltip_help_icon(text), new_tooltip_path(key: key)
    end
end
