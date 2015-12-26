module TooltipHelper

  # Shortcut to avoid adding the JavaScript include tag. All the actual tooltips are
  # dynamically created (including hard-coded tooltips). We need this snippet to do that.
  def enable_tooltips
    # Currently all tooltips are for editors only. Do not show to non-logged in users,
    # but let's be nice and show them to all logged in users, even if they are not editors.
    return unless current_user
    content_for :head do
      javascript_include_tag 'tooltips_create'
    end
    content_for :head do
      "\n<!-- Tooltips are enabled on this page. -->".html_safe
    end
  end

  # For rendering hard-coded tooltips. See explanation of key/scope in #parse_lookup_params
  # Much of this is duplicated in `tooltips_create.coffee` TODO fix
  def tooltip_icon key_param, scope: nil, disable_edit_link: false
    key = parse_lookup_params key_param, scope: scope
    tooltip = Tooltip.find_by(key: key)
    return "<!-- Disabled tooltip '#{key}' -->".html_safe if key_disabled? tooltip

    text =  if tooltip
              tooltip.try(:text) || "No tooltip text set. Click icon to edit."
            else
              # TODO take into account `disable_edit_link`
              "Could not find tooltip with key '#{key}'. Click icon to create."
            end
    tooltip_icon = image_tag 'help.png', class: 'help_icon tooltip', title: text

    if disable_edit_link
      # Disable linking the icon if the method was called with `disable_edit_link`
      tooltip_icon
    else
      # Tooltip icons are linked to the the tooltip, where it's possible to edit the text.
      # If someone asked for a tooltip with a key that we cannot find, then let's be nice
      # and link `new_tooltip_path` and pre-polulate it (via `new_populated_tooltip_link`)
      # with the key that was explicitly asked for.
      link_to (tooltip || new_populated_tooltip_link(key)) do
        tooltip_icon
      end
    end
  end

  private
    # Only returns true if we have a tooltip *and* its key is disabled, because we
    # want to notify editors about missing tooltips and encourage them to create them.
    def key_disabled? tooltip
      if tooltip && tooltip.key_disabled?
        # TODO log this somewhere
        $stderr.puts "A tooltip with a disabled key was called in a view."
        true
      end
    end

    # Used to populate tooltips that are linked from somewhere, but doesn't exist yet.
    # Pre-populates the key field with whatever was used to create the link.
    def new_populated_tooltip_link key
      new_tooltip_path key: key
    end

    # This method basically joins the params into a string, separated by periods if necessary.
    #
    # Accepts string(s) or symbol(s). These are all the same:
    #   'references.authors'
    #   :authors, scope: :references  # returns 'references.authors'
    #   :authors, scope, 'references'
    #
    # `scope` is optional and may be either a string, symbol, or an array containing either:
    #   :authors, scope: ['references', 'books']
    #   :authors, scope: [:references, :books]   # both returns 'references.books.authors'
    def parse_lookup_params key_param, scope: nil
      if scope.present?
        # Wrap `scope` to allow calling with either a single string/symbol or an array.
        scope_string = Array.wrap(scope).join(".")
        "#{scope_string}.#{key_param}"
      else
        "#{key_param}" # to_s to support symbols
      end
    end
end
