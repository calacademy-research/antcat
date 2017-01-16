module TooltipHelper
  # Includes the code that transforms the tooltip elements (both hard-coded and
  # selector-based) from <xzy class="tooltip" title="text"/> into tooltips.
  def enable_tooltips
    # Currently all tooltips are for editors only. Do not show to non-logged in users,
    # but let's be nice and show them to all logged in users, even if they are not editors.
    return unless current_user
    content_for(:head) { javascript_include_tag "tooltips" }
    if session[:show_missing_tooltips]
      content_for(:head) { javascript_include_tag "optimal-select.min" }
    end
    content_for :head do
      "\n<!-- Tooltips are enabled on this page. -->".html_safe
    end
  end

  # Call in views to render hard-coded tooltips.
  # See explanation of key/scope in #parse_lookup_params
  # Similar logic is duplicated in `tooltips.coffee`
  def tooltip_icon key_param, scope: nil, disable_edit_link: false
    # key = parse_lookup_params key_param, scope: scope
    tooltip = Tooltip.find_by(key: key_param, scope: scope)
    return "<!-- Disabled tooltip '#{key_param}' -->".html_safe if key_disabled? tooltip

    text =  if tooltip
              tooltip.try(:text) || "No tooltip text set. Click icon to edit."
            else
              "Could not find tooltip with key '#{key_param}' with page scope '#{scope}'. Click icon to create."
            end
    tooltip_icon = image_tag 'help.png', class: 'help_icon tooltip', title: text

    if disable_edit_link
      tooltip_icon
    else
      # Tooltip icons are linked to the the tooltip, where it's possible to edit the text.
      # If someone asked for a tooltip with a key that we cannot find, then let's be nice
      # and link `new_tooltip_path` and pre-polulate it (via `new_populated_tooltip_link`)
      # with the key that was explicitly asked for.
      link_to (tooltip || new_populated_tooltip_link(key_param)) do
        tooltip_icon
      end
    end
  end

  def toggle_tooltip_helper_tooltips_button
    verb = session[:show_missing_tooltips] ? "Hide" : "Show"
    link_to "#{verb} tooltips helper",
      toggle_tooltip_helper_tooltips_path, class: "btn-normal"
  end

  private
    # Only returns true if we have a tooltip *and* its key is disabled, because we
    # want to notify editors about missing tooltips and encourage them to create them.
    def key_disabled? tooltip
      if tooltip && tooltip.key_disabled?
        logger.info "A tooltip with a disabled key was called in a view."
        true
      end
    end

    # Used to populate tooltips that are linked from somewhere, but doesn't exist yet.
    # Pre-populates the key field with whatever was used to create the link.
    def new_populated_tooltip_link key
      new_tooltip_path key: key
    end
end
