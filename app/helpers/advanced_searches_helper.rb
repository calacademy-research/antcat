# coding: UTF-8
module AdvancedSearchesHelper
  include Formatters::AdvancedSearchHtmlFormatter

  def hash_to_params_string hash
    hash.keys.sort.inject(''.html_safe) do |string, key|
      key_and_value = %{#{key}=#{h hash[key]}}
      string << '&'.html_safe unless string.empty?
      string << key_and_value.html_safe
    end
  end
  
end
