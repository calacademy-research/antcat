# frozen_string_literal: true

module ActivitiesHelper
  def activities_link_for_trackable trackable
    activities_link trackable.class.name, trackable.id
  end

  def activities_link trackable_type, trackable_id
    return unless trackable_type

    sti_aware_type = trackable_type.constantize.base_class
    link_to(
      (antcat_icon("filter") + 'Activities'),
      activities_path(trackable_type: sti_aware_type, trackable_id: trackable_id),
      class: "btn-normal filter-activities-link"
    )
  end
end
