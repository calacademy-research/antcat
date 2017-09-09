# TODO rename anything feed --> activity.

module ActivitiesHelper
  def link_trackable_if_exists activity, label = nil, path: nil
    label = "##{activity.trackable_id}" unless label

    if activity.trackable
      link_to label, path ? path : activity.trackable
    else
      label
    end
  end

  def trackabe_type_to_human type
    type.titleize.downcase
  end
end
