# coding: UTF-8
class AuthorNameObserver < ActiveRecord::Observer
  def after_update author_name
    author_name.references.each {|reference| reference.refresh_author_names_caches}
  end
end
