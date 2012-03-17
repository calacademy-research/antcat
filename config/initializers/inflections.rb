# coding: UTF-8
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'genus', 'genera'
  inflect.irregular 'subgenus', 'subgenera'
  inflect.uncountable 'species'
  inflect.uncountable 'subspecies'
end
