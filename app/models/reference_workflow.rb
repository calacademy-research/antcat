# coding: UTF-8
class Reference < ActiveRecord::Base

  include Workflow
  workflow_column :review_status
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

end
