class AddKeyCache < ActiveRecord::Migration
  def up

    add_column :references, :key_cache, :string

    # this populates the cached key once, but new ones and modifications won't update the cache
    Reference.all.each do |reference|
      next if reference.kind_of? MissingReference
      key = ReferenceKey.new reference
      reference.update_attribute :key_cache, key.to_s
    end

  end
end
