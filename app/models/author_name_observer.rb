# coding: UTF-8
class AuthorNameObserver < ActiveRecord::Observer
  def after_update author_name
    author_name.references.each do |reference|
      reference.refresh_author_names_caches
      ReferenceFormatterCache.instance.invalidate reference
    end
  end
end
