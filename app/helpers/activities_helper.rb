# frozen_string_literal: true

module ActivitiesHelper
  def activities_link_for_trackable trackable
    activities_link trackable.class.name, trackable.id
  end

  def activities_link trackable_type, trackable_id
    return unless trackable_type
    return if trackable_type.in? Activity::DEPRECATED_TRACKABLE_TYPES

    type = trackable_type.constantize.base_class
    url = activities_path(trackable_type: type, trackable_id: trackable_id)
    link_to (antcat_icon("filter") + 'Activities'), url, class: "btn-normal filter-activities-link"
  end
end
