module TooltipHelper
  def enable_tooltips
    return unless current_user
    content_for(:head) { javascript_include_tag "tooltips" }
  end

  def tooltip_icon key_param, scope: nil
    tooltip = Tooltip.find_by(key: key_param, scope: scope)
    return if tooltip&.key_disabled?

    text =  if tooltip
              tooltip.text
            else
              "Could not find tooltip with key '#{key_param}' with page scope '#{scope}'. Click icon to create."
            end
    tooltip_icon = image_tag 'help.png', class: 'help_icon tooltip', title: text

    link_to tooltip || new_populated_tooltip_link(key_param) do
      tooltip_icon
    end
  end

  private

    def new_populated_tooltip_link key
      new_tooltip_path key: key
    end
end
