module DatabaseScripts
  class RedundantCurlyBracesInTaxtItems < DatabaseScript
    def results
      double_braces_count
    end

    def render
      "Found #{results} redundant curly brance(s)."
    end

    private
      def double_braces_count
        count = 0
        Taxt.models_with_taxts.each_field do |field, model|
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
