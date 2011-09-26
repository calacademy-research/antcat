# coding: UTF-8
class String
  def convert_asterisks_to_daggers!
    while gsub! /\*(<[^>]+?>)/, '\1*'; end
    gsub! /\*/, '&dagger;'
    self
  end
end
