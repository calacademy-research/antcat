# coding: UTF-8
class String
  def convert_asterisks_to_daggers
    string = dup
    while string.gsub! /\*(<[^>]+?>)/, '\1*'; end
    string.gsub! /\*/, '&dagger;'
    string
  end
end
