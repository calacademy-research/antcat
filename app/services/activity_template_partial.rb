# frozen_string_literal: true

# Returns the partial's full path like this:
# 1) If there is a partial named `events/_<event>.html.haml`, use that
# 2) If there is a partial named `_<trackable_type>.html.haml`, use that

class ActivityTemplatePartial
  include Service

  TEMPLATES_PATH = "activities/templates"

  attr_private_initialize [:event, :trackable_type]

  def call
    "#{TEMPLATES_PATH}/#{partial}"
  end

  private

    def partial
      partial_for_event || partial_for_trackable_type || raise('activity template missing')
    end

    def partial_for_event
      return unless partial_exists?("#{TEMPLATES_PATH}/events/_#{event}")
      "events/#{event}"
    end

    def partial_for_trackable_type
      underscored_trackable_type = trackable_type.underscore
      return unless partial_exists?("#{TEMPLATES_PATH}/_#{underscored_trackable_type}")

      underscored_trackable_type
    end

    def partial_exists? path
      File.file?("./app/views/#{path}.html.haml")
    end
end
