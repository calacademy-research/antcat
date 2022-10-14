# frozen_string_literal: true

# Returns the partial's full path like this:
# 1) The activity has no `#trackable_type` --> `events/_<event>` (like the event "approve_all_references")
# 2) There is a partial named `events/_<event>.html.haml` --> use that
# 3) There is a partial named `_<trackable_type>.html.haml` --> use that
# 4) Else --> `_default.html.haml`

class ActivityTemplatePartial
  include Service

  TEMPLATES_PATH = "activities/templates/"

  attr_private_initialize [:event, :trackable_type]

  def call
    return "#{TEMPLATES_PATH}events/#{event}" unless trackable_type
    "#{TEMPLATES_PATH}#{partial}"
  end

  private

    def partial
      partial_for_event || partial_for_trackable_type || "default"
    end

    def partial_for_event
      return unless partial_exists?("#{TEMPLATES_PATH}/events/_#{event}")
      "events/#{event}"
    end

    def partial_for_trackable_type
      underscored_trackable_type = trackable_type.underscore
      return unless partial_exists?("#{TEMPLATES_PATH}_#{underscored_trackable_type}")

      underscored_trackable_type
    end

    def partial_exists? path
      File.file?("./app/views/#{path}.html.haml")
    end
end
