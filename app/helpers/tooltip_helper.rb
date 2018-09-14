module TooltipHelper
  def enable_tooltips
    return unless current_user

    content_for(:head) { javascript_include_tag "tooltips" }

    if session[:show_missing_tooltips]
      content_for(:head) { javascript_include_tag "optimal-select.min" }
    end
  end

  # NOTE: Similar logic is duplicated in `tooltips.coffee`
  def tooltip_icon key_param, scope: nil, disable_edit_link: false
    tooltip = Tooltip.find_by(key: key_param, scope: scope)
    return if tooltip&.key_disabled?

    text =  if tooltip
              tooltip.try(:text) || "No tooltip text set. Click icon to edit."
            else
              "Could not find tooltip with key '#{key_param}' with page scope '#{scope}'. Click icon to create."
            end
    tooltip_icon = image_tag 'help.png', class: 'help_icon tooltip', title: text

    if disable_edit_link
      tooltip_icon
    else
      link_to tooltip || new_populated_tooltip_link(key_param) do
        tooltip_icon
      end
    end
  end

  def toggle_tooltip_helper_tooltips_button
    verb = session[:show_missing_tooltips] ? "Hide" : "Show"
    link_to "#{verb} tooltips helper", toggle_tooltip_helper_tooltips_path, class: "btn-normal"
  end

  private

    def new_populated_tooltip_link key
      new_tooltip_path key: key
    end
end
