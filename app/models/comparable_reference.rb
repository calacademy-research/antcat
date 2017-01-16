# Interface-ish for comparing references. Currently not used.
# TODO not used (December 2016).

class ComparableReference
  include ReferenceComparable

  # NOTE `:principal_author_last_name_cache` used to be `:author`, which pointed
  # to `principal_author_last_name` which pointed to the proper attribute
  # `principal_author_last_name_cache`.
  attr_accessor :principal_author_last_name_cache, :year, :title, :type,
    :series_volume_issue, :pagination

  def initialize hash = {}
    update hash
  end

  def update hash
    hash.each { |key, value| send "#{key}=", value }
  end

  def id
    object_id
  end

  def to_s
    "#{type}: #{author}, #{year}. #{title}. #{series_volume_issue}. #{pagination} #{doi}"
  end
end
