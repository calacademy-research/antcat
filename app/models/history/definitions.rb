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
        type_name: TAXT,
        type_label: 'Taxt (freeform text)',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 999,

        templates: {
          default: {
            content: '%<item_taxts>s'
          }
        },

        validates_presence_of: [:taxt]
      },
      TYPE_SPECIMEN_DESIGNATION = 'TypeSpecimenDesignation' => {
        type_name: TYPE_SPECIMEN_DESIGNATION,
        type_label: 'Type specimen designation',
        ranks: SPECIES_GROUP_LABEL,

        group_order: 10,

        templates: {
          default: {
            content: '%<designation_type>s: %<citation>s.',
            vars: ->(o) { { designation_type: o.subtype.underscore.humanize, citation: o.citation } }
          }
        },

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
        type_name: FORM_DESCRIPTIONS,
        type_label: 'Form descriptions (additional)',
        ranks: SPECIES_GROUP_LABEL,

        group_order: 20,
        group_key: ->(o) { o.type },

        templates: {
          default: {
            content: '%<grouped_item_taxts>s.'
          }
        },

        groupable_template_content: '%<citation>s (%<forms>s)',
        groupable_template_vars: ->(o) { { citation: o.citation, forms: o.text_value } },

        validates_presence_of: [:text_value, :reference, :pages]
      },
      COMBINATION_IN = 'CombinationIn' => {
        type_name: COMBINATION_IN,
        type_label: 'Combination in',
        ranks: SPECIES_GROUP_LABEL,

        group_order: 30,
        group_key: ->(o) { [o.type, 'object_taxon_id', o.object_taxon_id] },

        templates: {
          default: {
            content: 'Combination in {tax %<object_taxon_id>i}: %<grouped_item_taxts>s.',
            vars: ->(o) { o.slice(:object_taxon_id) }
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:object_taxon, :reference, :pages]
      },
      # Plan: To be merged with `SeniorSynonymOf` once migrated and synced, probably as `SubjectiveSynonym`.
      JUNIOR_SYNONYM_OF = 'JuniorSynonymOf' => {
        type_name: JUNIOR_SYNONYM_OF,
        type_label: 'Junior synonym of',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 40,
        group_key: ->(o) { [o.type, 'object_protonym_id', o.object_protonym_id] },

        templates: {
          default: {
            content: 'Junior synonym of {%<object_protonym_tag>s %<object_protonym_id>i}: %<grouped_item_taxts>s.',
            vars: ->(o) {
              {
                object_protonym_id: o.object_protonym_id,
                object_protonym_tag: o.force_author_citation? ? 'prottac' : 'prott'
              }
            }
          },
          object: {
            content: 'Senior synonym of {%<subject_protonym_tag>s %<subject_protonym_id>i}: %<grouped_item_taxts>s.',
            vars: ->(o) {
              {
                subject_protonym_id: o.protonym_id,
                subject_protonym_tag: o.force_author_citation? ? 'prottac' : 'prott'
              }
            },
            group_key: ->(o) { [o.type, 'as_object', 'subject_protonym_id', o.protonym_id] }
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:object_protonym, :reference, :pages],
        allow_force_author_citation: true
      },
      # Plan: Same as with `JuniorSynonymOf`.
      SENIOR_SYNONYM_OF = 'SeniorSynonymOf' => {
        type_name: SENIOR_SYNONYM_OF,
        type_label: 'Senior synonym of',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 45,
        group_key: ->(o) { [o.type, 'object_protonym_id', o.object_protonym_id] },

        templates: {
          default: {
            content: 'Senior synonym of {%<object_protonym_tag>s %<object_protonym_id>i}: %<grouped_item_taxts>s.',
            vars: ->(o) {
              {
                object_protonym_id: o.object_protonym_id,
                object_protonym_tag: o.force_author_citation? ? 'prottac' : 'prott'
              }
            }
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:object_protonym, :reference, :pages],
        allow_force_author_citation: true
      },
      STATUS_AS_SPECIES = 'StatusAsSpecies' => {
        type_name: STATUS_AS_SPECIES,
        type_label: 'Status as species',
        ranks: SPECIES_GROUP_LABEL,

        group_order: 50,
        group_key: ->(o) { [o.type] },

        templates: {
          default: {
            content: 'Status as species: %<grouped_item_taxts>s.'
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:reference, :pages]
      },
      SUBSPECIES_OF = 'SubspeciesOf' => {
        type_name: SUBSPECIES_OF,
        type_label: 'Subspecies of',
        ranks: SPECIES_GROUP_LABEL,

        group_order: 60,
        group_key: ->(o) { [o.type, 'object_protonym_id', o.object_protonym_id] },

        templates: {
          default: {
            content: 'Subspecies of {%<object_protonym_tag>s %<object_protonym_id>i}: %<grouped_item_taxts>s.',
            vars: ->(o) {
              {
                object_protonym_id: o.object_protonym_id,
                object_protonym_tag: o.force_author_citation? ? 'prottac' : 'prott'
              }
            }
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:object_protonym, :reference, :pages],
        allow_force_author_citation: true
      },
      JUNIOR_PRIMARY_HOMONYM_OF = 'JuniorPrimaryHomonymOf' => {
        type_name: JUNIOR_PRIMARY_HOMONYM_OF,
        type_label: 'Junior primary homonym of',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 70,

        templates: {
          default: {
            content: '[Junior primary homonym of {taxac %<object_taxon_id>i}%<citation>s.]',
            vars: ->(o) {
              {
                object_taxon_id: o.object_taxon_id,
                citation: (" (#{o.citation})" if o.citation)
              }
            }
          }
        },

        validates_presence_of: [:object_taxon],
        optional_attributes: [:reference, :pages]
      },
      JUNIOR_PRIMARY_HOMONYM_OF_HARDCODED_GENUS = 'JuniorPrimaryHomonymOfHardcodedGenus' => {
        type_name: JUNIOR_PRIMARY_HOMONYM_OF_HARDCODED_GENUS,
        type_label: 'Junior primary homonym of hardcoded genus',
        ranks: GENUS_GROUP_LABEL,

        group_order: 71,

        templates: {
          default: {
            content: '[Junior primary homonym of {unmissing %<hardcoded_genus>s}%<citation>s.]',
            vars: ->(o) {
              {
                hardcoded_genus: o.text_value,
                citation: (" [#{o.citation}]" if o.citation)
              }
            }
          }
        },

        validates_presence_of: [:text_value],
        optional_attributes: [:reference, :pages]
      },
      JUNIOR_SECONDARY_HOMONYM_OF = 'JuniorSecondaryHomonymOf' => {
        type_name: JUNIOR_SECONDARY_HOMONYM_OF,
        type_label: 'Junior secondary homonym of',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 72,

        templates: {
          default: {
            content: '[Junior secondary homonym of {taxac %<object_taxon_id>i}%<citation>s.]',
            vars: ->(o) {
              {
                object_taxon_id: o.object_taxon_id,
                citation: (" (#{o.citation})" if o.citation)
              }
            }
          }
        },

        validates_presence_of: [:object_taxon],
        optional_attributes: [:reference, :pages]
      },
      HOMONYM_REPLACED_BY = 'HomonymReplacedBy' => {
        type_name: HOMONYM_REPLACED_BY,
        type_label: 'Replacement name (homonym replaced by)',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 74,

        templates: {
          default: {
            content: 'Replacement name: {taxac %<object_taxon_id>i}%<citation>s.',
            vars: ->(o) {
              {
                object_taxon_id: o.object_taxon_id,
                citation: (" (#{o.citation})" if o.citation)
              }
            }
          }
        },

        validates_presence_of: [:object_taxon],
        optional_attributes: [:reference, :pages]
      },
      REPLACEMENT_NAME_FOR = 'ReplacementNameFor' => {
        type_name: REPLACEMENT_NAME_FOR,
        type_label: 'Replacement name for',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 75,

        templates: {
          default: {
            content: 'Replacement name for {taxac %<object_taxon_id>i}%<citation>s.%<trailers>s',
            vars: ->(o) {
              {
                object_taxon_id: o.object_taxon_id,
                citation: (" (#{o.citation})" if o.citation),
                trailers: (
                  # TODO: Hmm.
                  trailer_types = [JUNIOR_PRIMARY_HOMONYM_OF, JUNIOR_SECONDARY_HOMONYM_OF, JUNIOR_PRIMARY_HOMONYM_OF_HARDCODED_GENUS]
                  if (items = o.object_taxon.protonym_history_items.where(type: trailer_types)).present?
                    " #{items.map(&:to_taxt).join('; ')}"
                  end
                )
              }
            }
          }
        },

        validates_presence_of: [:object_taxon],
        optional_attributes: [:reference, :pages]
      },
      UNAVAILABLE_NAME = 'UnavailableName' => {
        type_name: UNAVAILABLE_NAME,
        type_label: 'Unavailable name',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 100,

        templates: {
          default: {
            content: 'Unavailable name%<citation>s.',
            vars: ->(o) {
              {
                object_taxon_id: o.object_taxon_id,
                citation: (" (#{o.citation})" if o.citation)
              }
            }
          }
        },

        validates_presence_of: [],
        optional_attributes: [:reference, :pages]
      }
    }

    TYPES = TYPE_DEFINITIONS.keys
    VISIBLE_AS_OBJECT = [
      JUNIOR_SYNONYM_OF
    ]
  end
end
