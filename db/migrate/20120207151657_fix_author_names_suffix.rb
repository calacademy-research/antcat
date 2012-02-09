class FixAuthorNamesSuffix < ActiveRecord::Migration
  def up
    for reference in Reference.where("author_names_suffix LIKE '%Citrus%'").all
      if reference.author_names_suffix.match /.*^string.*'([^']+)'$.*/m
        reference.update_attribute :author_names_suffix, $1
        puts $1
      end
    end
    for reference in Reference.where("author_names_suffix LIKE '%Citrus%'").all
      reference.update_attribute :author_names_suffix, nil
    end
  end

  def down
  end
end
