# frozen_string_literal: true

# [grep:history_type].

module History
  module Definitions
    RANK_LABELS = [
      ANY_RANK_GROUP_LABEL = 'Any/all rank (-groups)',
      FAMILY_GROUP_LABEL = 'Family-group',
      GENUS_GROUP_LABEL = 'Genus-group',
      SPECIES_GROUP_LABEL = 'Species-group'
    ]

    TYPE_DEFINITIONS = {
      TAXT = 'Taxt' => {
        type_label: 'Taxt (freeform text)',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 999,

        item_template: '%<item_taxts>s',

        validates_presence_of: [:taxt]
      },
      TYPE_SPECIMEN_DESIGNATION = 'TypeSpecimenDesignation' => {
        type_label: 'Type specimen designation',
        ranks: SPECIES_GROUP_LABEL,

        group_order: 10,

        item_template: '%<designation_type>s: %<citation>s.',
        item_template_vars: ->(o) { { designation_type: o.subtype.underscore.humanize, citation: o.citation } },

        subtypes: TYPE_SPECIMEN_DESIGNATION_SUBTYPES = [
          LECTOTYPE_DESIGNATION = 'LectotypeDesignation',
          NEOTYPE_DESIGNATION = 'NeotypeDesignation'
        ],
        subtype_options: [
          ['Lectotype designation', LECTOTYPE_DESIGNATION],
          ['Neotype designation', NEOTYPE_DESIGNATION]
        ],

        validates_presence_of: [:subtype, :reference, :pages]
      },
      FORM_DESCRIPTIONS = 'FormDescriptions' => {
        type_label: 'Form descriptions (additional)',
        ranks: SPECIES_GROUP_LABEL,

        group_order: 20,
        group_key: ->(o) { o.type },

        item_template: '%<grouped_item_taxts>s.',

        groupable_item_template: '%<citation>s (%<forms>s)',
        groupable_item_template_vars: ->(o) { { citation: o.citation, forms: o.text_value } },

        validates_presence_of: [:text_value, :reference, :pages]
      },
      COMBINATION_IN = 'CombinationIn' => {
        type_label: 'Combination in',
        ranks: SPECIES_GROUP_LABEL,

        group_order: 30,
        group_key: ->(o) { [o.type, 'object_taxon_id', o.object_taxon_id] },

        item_template: 'Combination in {tax %<object_taxon_id>i}: %<grouped_item_taxts>s.',
        item_template_vars: ->(o) { o.slice(:object_taxon_id) },

        groupable_item_template: '%<citation>s',
        groupable_item_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:object_taxon, :reference, :pages]
      },
      # Plan: To be merged with `SeniorSynonymOf` once migrated and synced, probably as `SubjectiveSynonym`.
      JUNIOR_SYNONYM_OF = 'JuniorSynonymOf' => {
        type_label: 'Junior synonym of',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 40,
        group_key: ->(o) { [o.type, 'object_protonym_id', o.object_protonym_id] },

        item_template: 'Junior synonym of {%<object_protonym_tag>s %<object_protonym_id>i}: %<grouped_item_taxts>s.',
        item_template_vars:  ->(o) {
          {
            object_protonym_id: o.object_protonym_id,
            object_protonym_tag: o.force_author_citation? ? 'prottac' : 'prott'
          }
        },

        groupable_item_template: '%<citation>s',
        groupable_item_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:object_protonym, :reference, :pages],
        allow_force_author_citation: true
      },
      # Plan: Same as with `JuniorSynonymOf`.
      SENIOR_SYNONYM_OF = 'SeniorSynonymOf' => {
        type_label: 'Senior synonym of',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 45,
        group_key: ->(o) { [o.type, 'object_protonym_id', o.object_protonym_id] },

        item_template: 'Senior synonym of {%<object_protonym_tag>s %<object_protonym_id>i}: %<grouped_item_taxts>s.',
        item_template_vars:  ->(o) {
          {
            object_protonym_id: o.object_protonym_id,
            object_protonym_tag: o.force_author_citation? ? 'prottac' : 'prott'
          }
        },

        groupable_item_template: '%<citation>s',
        groupable_item_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:object_protonym, :reference, :pages],
        allow_force_author_citation: true
      },
      STATUS_AS_SPECIES = 'StatusAsSpecies' => {
        type_label: 'Status as species',
        ranks: SPECIES_GROUP_LABEL,

        group_order: 50,
        group_key: ->(o) { [o.type] },

        item_template: 'Status as species: %<grouped_item_taxts>s.',

        groupable_item_template: '%<citation>s',
        groupable_item_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:reference, :pages]
      },
      SUBSPECIES_OF = 'SubspeciesOf' => {
        type_label: 'Subspecies of',
        ranks: SPECIES_GROUP_LABEL,

        group_order: 60,
        group_key: ->(o) { [o.type, 'object_protonym_id', o.object_protonym_id] },

        item_template: 'Subspecies of {prott %<object_protonym_id>i}: %<grouped_item_taxts>s.',
        item_template_vars: ->(o) { o.slice(:object_protonym_id) },

        groupable_item_template: '%<citation>s',
        groupable_item_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:object_protonym, :reference, :pages]
      },
      REPLACEMENT_NAME = 'ReplacementName' => {
        type_label: 'Replacement name',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 70,

        item_template: 'Replacement name: {prottac %<object_protonym_id>i}%<citation>s.',
        item_template_vars: ->(o) {
          {
            object_protonym_id: o.object_protonym_id,
            citation: (" (#{o.citation})" if o.citation)
          }
        },

        validates_presence_of: [:object_protonym],
        optional_attributes: [:reference, :pages]
      },
      REPLACEMENT_NAME_FOR = 'ReplacementNameFor' => {
        type_label: 'Replacement name for',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 75,

        item_template: 'Replacement name for {prottac %<object_protonym_id>i}%<citation>s.%<legacy_taxt>s',
        item_template_vars: ->(o) {
          {
            object_protonym_id: o.object_protonym_id,
            citation: (" (#{o.citation})" if o.citation),
            legacy_taxt: (" #{o.taxt}" if o.taxt?)
          }
        },

        validates_presence_of: [:object_protonym],
        optional_attributes: [:taxt, :reference, :pages]
      },
      UNAVAILABLE_NAME = 'UnavailableName' => {
        type_label: 'Unavailable name',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 100,

        item_template: 'Unavailable name%<citation>s.',
        item_template_vars: ->(o) {
          {
            object_taxon_id: o.object_taxon_id,
            citation: (" (#{o.citation})" if o.citation)
          }
        },

        validates_presence_of: [],
        optional_attributes: [:reference, :pages]
      }
    }
    TYPES = TYPE_DEFINITIONS.keys
  end
end
