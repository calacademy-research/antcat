class AddInlineCitationColumn < ActiveRecord::Migration
  def up
    add_column :references, :inline_citation_cache, :text
  end

  def down
    remove_column :references, :inline_citation_cache
  end
end
