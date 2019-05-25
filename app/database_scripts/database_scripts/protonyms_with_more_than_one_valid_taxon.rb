module DatabaseScripts
  class ProtonymsWithMoreThanOneValidTaxon < DatabaseScript
    include Rails.application.routes.url_helpers
    include ActionView::Helpers::UrlHelper

    def results
      Protonym.joins(:taxa).where(taxa: { status: Status::VALID }).group(:protonym_id).having('COUNT(protonym_id) > 1')
    end

    def render
      as_table do |t|
        t.header :id, :protonym
        t.rows do |protonym|
          [
            protonym.id,
            link_to(protonym.decorate.format_name, protonym_path(protonym))
          ]
        end
      end
    end
  end
end

__END__

description: >
   It is fine for a protonym to have more than one valid taxa if it is above the rank of
   genus (one valid taxa in rank: tribe, subfamily or family).

topic_areas: [protonyms]
tags: [regression-test]
