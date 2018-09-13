# TODO migrate nil review states to "none".
# `Reference.where(review_state: nil).last` --> created_at: "2013-07-09 01:01:35"

class Reference < ApplicationRecord
  include Workflow

  workflow_column :review_state

  workflow do
    state :none do
      event :start_reviewing, transitions_to: :reviewing
    end
    state :reviewing do
      event :finish_reviewing, transitions_to: :reviewed
    end
    state :reviewed do
      event :restart_reviewing, transitions_to: :reviewing
    end
  end

  def restart_reviewing
    create_activity :restart_reviewing
  end

  def finish_reviewing
    create_activity :finish_reviewing
  end

  def start_reviewing
    create_activity :start_reviewing
  end
end
