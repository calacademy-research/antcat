# frozen_string_literal: true

class TaxonHistoryItem < ApplicationRecord
  include Trackable

  # TODO: WIP, see https://github.com/calacademy-research/antcat/issues/779
  VIRTUAL_HISTORY_ITEM_CANDIDATES = [
    # Good next candidates to work on.
    # Good candidate because it often appears first in the list, and no tax tags.
    VHIC_FORM_DESCRIPTION = ["taxt REGEXP ?", "^{ref [0-9]+}: [0-9]+ \\("],
    # Good candiate because it ususally appears last in the list, and no tax tags.
    VHIC_SEE_ALSO =         ["taxt LIKE ?", "See also: {ref %"],

    #### Synonym of.
    # TODO: These should probably be "Junior synonym of ...".
    VHIC_SYNONYM_OF =                    ["taxt LIKE ?", "Synonym of%"],
    VHIC_SENIOR_SYNONYM_OF =             ["taxt LIKE ?", "Senior synonym of%"],
    VHIC_JUNIOR_SYNONYM_OF =             ["taxt LIKE ?", "Junior synonym of%"],
    VHIC_PROVISIONAL_JUNIOR_SYNONYM_OF = ["taxt LIKE ?", "Provisional junior synonym o%"],

    ### Homonym of.
    # Also without brackets "Junior primary homonym of%".
    VHIC_JUNIOR_PRIMARY_HOMONYM_OF =              ["taxt LIKE ?", "[Junior primary homonym of%"],
    # Also without brackets "Junior secondary homonym of%".
    VHIC_JUNIOR_SECONDARY_HOMONYM =               ["taxt LIKE ?", "[Junior secondary homonym%"],
    VHIC_UNRESOLVED_JUNIOR_PRIMARY_HOMONYM_OF =   ["taxt LIKE ?", "[Unresolved junior primary homonym of%"],
    VHIC_UNRESOLVED_JUNIOR_SECONDARY_HOMONYM_OF = ["taxt LIKE ?", "[Unresolved junior secondary homonym of%"],

    # Placement/raised/revived/etc.
    VHIC_SUBSPECIES_OF =             ["taxt LIKE ?", "Subspecies of%"],
    VHIC_RAISED_TO_SPECIES =         ["taxt LIKE ?", "Raised to species%"],
    VHIC_REVIVED_STATUS_AS_SPECIES = ["taxt LIKE ?", "Revived status as species%"],
    VHIC_REVIVED_FROM_SYNONYMY =     ["taxt LIKE ?", "Revived from synonymy%"],
    VHIC_CURRENTLY_SUBSPECIES_OF =   ["taxt LIKE ?", "Currently subspecies of%"],
    VHIC_STATUS_AS_SPECIES =         ["taxt LIKE ?", "Status as species%"],

    # Status-ish.
    VHIC_NOMEN_NUDUM =      ["taxt = ?", '<i>Nomen nudum</i>'],
    VHIC_UNAVAILABLE_NAME = ["taxt LIKE ?", "Unavailable name%"],

    # Unidentifiable etc.
    VHIC_UNIDENTIFIABLE_TAXON =    ["taxt LIKE ?", "Unidentifiable taxon%"],
    VHIC_UNRECOGNISABLE_TAXON =    ["taxt LIKE ?", "Unrecognisable taxon%"],
    VHIC_UNIDENTIFIABLE_TO_GENUS = ["taxt LIKE ?", "Unidentifiable to genus%"],
    VHIC_SUBGENUS_INDETERMINATE =  ["taxt LIKE ?", "Subgenus indeterminate%"],

    # Misc.
    # Also "Also given as new in%".
    VHIC_ALSO_DESCRIBED_AS_NEW_BY =     ["taxt LIKE ?", "[Also described as new by%"],
    VHIC_REPLACEMENT_NAME =             ["taxt LIKE ?", "Replacement name%"],
    VHIC_UNNECESSARY_REPLACEMENT_NAME = ["taxt LIKE ?", "Unnecessary replacement name%"],
    VHIC_FIRST_AVAILABLE_USE_OF =       ["taxt LIKE ?", "[First available use of%"],
    # Also without brackets "Name misspelled as%".
    VHIC_MISSPELLED_AS =                ["taxt LIKE ?", "[Misspelled as%"],
    VHIC_COMBINATION_IN =               ["taxt LIKE ?", "Combination in%"]
  ]

  NO_REF_OR_TAX_TAG = "taxt NOT LIKE '%{ref %' AND taxt NOT LIKE '%{tax %' AND taxt NOT LIKE '%{taxac %'"

  belongs_to :taxon

  validates :taxt, presence: true
  validates :rank, inclusion: { in: Rank::TYPE_SPECIFIC_TAXON_HISTORY_ITEM_RANKS, allow_nil: true }

  before_validation :cleanup_taxts

  strip_attributes only: [:rank], replace_newlines: true

  scope :persisted, -> { where.not(id: nil) }

  # :nocov:
  scope :vhic_unknown, -> do
    scope = self
    VIRTUAL_HISTORY_ITEM_CANDIDATES.each do |where_filter|
      scope = scope.where.not(where_filter)
    end
    scope
  end
  # :nocov:

  acts_as_list scope: :taxon
  has_paper_trail
  strip_attributes only: [:taxt], replace_newlines: true
  trackable parameters: proc { { taxon_id: taxon_id } }

  def self.search search_query, search_type
    search_type = search_type.presence || 'LIKE'
    raise unless search_type.in? ["LIKE", "REGEXP"]

    q = search_type == "LIKE" ? "%#{search_query}%" : search_query
    where("taxt #{search_type} :q", q: q)
  end

  def ids_from_tax_tags
    taxt.scan(Taxt::TAX_OR_TAXAC_TAG_REGEX).flatten.map(&:to_i)
  end

  private

    def cleanup_taxts
      self.taxt = Taxt::Cleanup[taxt]
    end
end
