# frozen_string_literal: true

class AddFeaturedToWikipages < ActiveRecord::Migration[6.0]
  def change
    add_column :wiki_pages, :featured, :boolean, default: false, null: false
  end
end
