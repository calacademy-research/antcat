# Required after reinstating reference caching, or caches with brokens links
# will appear in the catalog. Light version of this migration:
# `ReferenceFormatterCache.instance.invalidate_all`

class RegenerateReferenceCaches < ActiveRecord::Migration
  def up
    # Ignore in future migrations.
    # ReferenceFormatterCache.instance.regenerate_all
  end
end
