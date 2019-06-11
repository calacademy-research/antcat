module DatabaseScripts
  class SpreadOutPrimaryTypeInformation < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper
    include SpreadOutTypeInformationHelper

    def column_name
      :primary_type_information
    end
  end
end

__END__

description: >
  Migrating this field from the taxon table to the protonym table would create a conflict.


  Protonyms with a dash in the 'Not identical?' column can be solved by script (same content, so not really conflicts).

tags: [new!]
topic_areas: [protonyms]
