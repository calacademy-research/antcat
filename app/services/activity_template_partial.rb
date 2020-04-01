# frozen_string_literal: true

# Returns the partial's full path like this:
# 1) The activity has no `#trackable_type` --> `actions/_<action>` (like the action "approve_all_references")
# 2) There is a partial named `actions/_<action>.haml` --> use that
# 3) There is a partial named `_<trackable_type>.haml` --> use that
# 4) Else --> `_default.haml`

class ActivityTemplatePartial
  include Service

  TEMPLATES_PATH = "activities/templates/"

  def initialize action:, trackable_type:
    @action = action
    @trackable_type = trackable_type
  end

  def call
    return "#{TEMPLATES_PATH}actions/#{action}" unless trackable_type
    "#{TEMPLATES_PATH}#{partial}"
  end

  private

    attr_reader :action, :trackable_type

    def partial
      partial_for_action || partial_for_trackable_type || "default"
    end

    def partial_for_action
      return unless partial_exists?("#{TEMPLATES_PATH}/actions/_#{action}")
      "actions/#{action}"
    end

    def partial_for_trackable_type
      underscored_trackable_type = trackable_type.underscore
      return unless partial_exists?("#{TEMPLATES_PATH}_#{underscored_trackable_type}")
      underscored_trackable_type
    end

    def partial_exists? path
      File.file?("./app/views/#{path}.haml")
    end
end
