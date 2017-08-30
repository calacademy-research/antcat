require 'antcat_rake_utils'
include AntCat::RakeUtils

module DatabaseScripts
  class RedundantCurlyBracesInTaxtItems < DatabaseScript
    def results
      double_braces_count
    end

    def no_database_issues_on_on
      0
    end

    # When this method isn't implemented, the code tries to figure out
    # how to render `results` based on its class.
    def render
      if cached_results == no_database_issues_on_on
        no_database_issues
      else
        "Found #{cached_results} redundant curly brances."
      end
    end

    private
      def double_braces_count
        count = 0
        models_with_taxts.each_field do |field, model|
          count += model.where("#{field} LIKE '%}}%'").count
        end
        count
      end
  end
end

__END__
description: >
    Previously some 3000 taxt items contained redundant trailing
    braces such as '{ref 124002}}: 55.'
tags: [regression-test]
topic_areas: [taxt]
