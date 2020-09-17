# frozen_string_literal: true

module ReferenceStepsHelpers
  module_function

  def find_reference_by_key key_with_year
    last_name, year = key_with_year.split(',')
    Reference.where("author_names_string_cache LIKE ?", "#{last_name}%").find_by!(year: year)
  end

  def find_or_create_author_name author_name_name
    AuthorName.find_by(name: author_name_name) || FactoryBot.create(:author_name, name: author_name_name)
  end
end
