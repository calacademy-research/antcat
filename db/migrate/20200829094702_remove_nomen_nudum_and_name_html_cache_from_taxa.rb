# frozen_string_literal: true

class RemoveNomenNudumAndNameHtmlCacheFromTaxa < ActiveRecord::Migration[6.0]
  def change
    # Remove deprecated column that has been moved to `protonyms.nomen_nudum`.
    remove_column :taxa, :nomen_nudum, :boolean, default: false, null: false

    # Remove deprecated column that we do not really need.
    remove_column :taxa, :name_html_cache, :string
  end
end
