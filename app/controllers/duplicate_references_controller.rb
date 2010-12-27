class DuplicateReferencesController < ApplicationController
  def index
    @references = Reference.find_by_sql %q{
      SELECT DISTINCT nr.* FROM
        `references` r JOIN `references` nr ON r.nested_reference_id = nr.id
        WHERE r.type = 'NestedReference'
        ORDER by nr.author_names_string, nr.year
      }
  end

end
