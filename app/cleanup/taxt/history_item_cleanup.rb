# frozen_string_literal: true

module Taxt
  class HistoryItemCleanup
    # TODO: WIP, see https://github.com/calacademy-research/antcat/issues/779
    VIRTUAL_HISTORY_ITEM_CANDIDATES = [
      # Good next candidates to work on.
      # Good candidate because it often appears first in the list, and no tax tags.
      VHIC_FORM_DESCRIPTION = ["taxt REGEXP ?", "^{ref [0-9]+}: [0-9]+ \\("],
      # Good candiate because it ususally appears last in the list, and no tax tags.
      VHIC_SEE_ALSO =         ["taxt LIKE ?", "See also: {ref %"],

      #### Synonym of.
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
  end
end
