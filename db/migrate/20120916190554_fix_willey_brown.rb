class FixWilleyBrown < ActiveRecord::Migration
  def up
    missing_reference = MissingReference.find_by_bolton_key_cache 'Willey Brown 1983'
    found_reference = Reference.find_by_author_names_string_cache 'Willey, R. B.; Brown, W. L., Jr.'
    raise unless found_reference
    missing_reference.replace_with found_reference
  end

  def down
  end
end
