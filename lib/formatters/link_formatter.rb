# coding: UTF-8
module Formatters::LinkFormatter
  include ActionView::Helpers::TagHelper
  include ERB::Util

  def link contents, href, attributes = {}
    attributes = attributes.dup
    attributes[:target] = '_blank' unless attributes.include? :target
    attributes.delete(:target) if attributes[:target].nil?
    attributes[:href] = href
    attributes_string = attributes.keys.sort.inject(''.html_safe) do |string, key|
      string << "#{key}=\"#{h attributes[key]}\" ".html_safe
    end.strip.html_safe
    '<a '.html_safe + attributes_string + '>'.html_safe + contents + '</a>'.html_safe
  end

  def link_to_external_site label, url
    link label, url, class: 'link_to_external_site'
  end

end
