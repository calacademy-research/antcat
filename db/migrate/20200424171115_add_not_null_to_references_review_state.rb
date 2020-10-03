# frozen_string_literal: true

class AddNotNullToReferencesReviewState < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      change_column_default :references, :review_state, from: nil, to: 'none'
      change_column_null :references, :review_state, false
    end
  end
end
