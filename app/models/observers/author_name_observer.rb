class AuthorNameObserver < ActiveRecord::Observer
  def after_update author_name
    references = author_name.references.reload
    references.each &:refresh_author_names_caches
    references.each &:invalidate_caches
  end
end
