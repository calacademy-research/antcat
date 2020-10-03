# frozen_string_literal: true

class AddFeaturedToWikipages < ActiveRecord::Migration[6.0]
  def change
    safety_assured do
      add_column :wiki_pages, :featured, :boolean, default: false, null: false
    end
  end
end
