class AddInlineCitationColumn < ActiveRecord::Migration
  def up
    add_column :references, :inline_citation_cache, :string
  end

  def down
    remove_column :references, :inline_citation_cache
  end
end
