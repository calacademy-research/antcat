class KillZombieAuthors < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute 'DELETE authors.* FROM authors LEFT JOIN author_names ON authors.id = author_names.author_id WHERE author_names.id IS NULL'
  end

  def down
  end
end
