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

    INCERTAE_SEDIS_IN_PREFIXES = {
      'IncertaeSedis' => '<i>Incertae sedis</i>',
      'UnidentifiableTaxon' => 'Unidentifiable taxon; <i>incertae sedis</i>',
      'UnidentifiableToGenus' => 'Unidentifiable to genus; <i>incertae sedis</i>'
    }.freeze

    # Genus- and family-group lines name their subject first, as in Bolton's catalogue ("Pheidole in Myrmicinae,
    # Pheidolini: ..."). The subject is the protonym's terminal taxon ({prott}, or {prottac} with
    # `force_author_citation`), so a converted page reads exactly as the free text did (2026-11-14).
    HIGHER_NAME_SUBJECT = ->(o) { "{#{o.force_author_citation? ? 'prottac' : 'prott'} #{o.protonym_id}}" }

    AS_RANK_OF_RANKS = {
      'Subgenus' => 'subgenus',
      'Tribe' => 'tribe',
      'Subtribe' => 'subtribe',
      'Subfamily' => 'subfamily'
    }.freeze

    AS_SYNONYM_OF_KINDS = {
      'Junior' => 'junior',
      'Senior' => 'senior'
    }.freeze

    # Emendations, ICZN Art. 33.2 (Brian Fisher, 14 Nov 2026). A change of a gender ending is a mandatory change
    # (Art. 34.2), not an emendation (Art. 33.1), and has no history item: part of speech and the three spellings
    # on the protonym carry it. TaxonWorks: Justified and DeemedJustified as Incorrect original spelling (the
    # original spelling, NOMEN_0000044) with the emending work cited; Unjustified as Unjustified emendation
    # (NOMEN_0000278), between the emendation's own record and this name.
    EMENDATION_LEADS = {
      # Arts. 32.5, 33.2.2: corrects an incorrect original spelling; takes the original author and date.
      'Justified' => 'Justified emendation of spelling to %<spelling>s',
      # Art. 33.2.3: an available name with its own author and date; its record has the status
      # "unjustified emendation".
      'Unjustified' => 'Unjustified emendation of spelling to {tax %<object_taxon_id>i}',
      # Art. 33.2.3.1: unjustified, but in prevailing usage and attributed to the original author and date, so
      # deemed a justified emendation.
      'DeemedJustified' => 'Emendation of spelling to %<spelling>s, unjustified but in prevailing usage and ' \
                           'deemed justified (Art. 33.2.3.1)'
    }.freeze

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
        # `force_author_citation` is part of the key so that lines with and without
        # an author citation for the same genus are not merged under one tag.
        group_key: ->(o) { [o.type, 'object_taxon_id', o.object_taxon_id, o.force_author_citation?] },

        templates: {
          default: {
            content: 'Combination in {%<object_taxon_tag>s %<object_taxon_id>i}: %<grouped_item_taxts>s.',
            vars: ->(o) {
              {
                object_taxon_id: o.object_taxon_id,
                object_taxon_tag: o.force_author_citation? ? 'taxac' : 'tax'
              }
            }
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:object_taxon, :reference, :pages],
        allow_force_author_citation: true
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
      UNAVAILABLE_INFRASUBSPECIFIC_NAME = 'UnavailableInfrasubspecificName' => {
        type_name: UNAVAILABLE_INFRASUBSPECIFIC_NAME,
        type_label: 'As unavailable (infrasubspecific) name',
        ranks: SPECIES_GROUP_LABEL,

        # After "Combination in", before the status lines (canonical order, claude/HISTORY_ORDER.md).
        group_order: 35,
        group_key: ->(o) { [o.type] },

        templates: {
          default: {
            content: 'As unavailable (infrasubspecific) name: %<grouped_item_taxts>s.'
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:reference, :pages]
      },
      DECLARED_UNAVAILABLE_INFRASUBSPECIFIC_NAME = 'DeclaredUnavailableInfrasubspecificName' => {
        type_name: DECLARED_UNAVAILABLE_INFRASUBSPECIFIC_NAME,
        type_label: 'Declared as unavailable (infrasubspecific) name',
        ranks: SPECIES_GROUP_LABEL,

        group_order: 36,
        group_key: ->(o) { [o.type] },

        templates: {
          default: {
            content: 'Declared as unavailable (infrasubspecific) name: %<grouped_item_taxts>s.'
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:reference, :pages]
      },
      FIRST_AVAILABLE_USE_UNAVAILABLE_INFRASUBSPECIFIC = 'FirstAvailableUseUnavailableInfrasubspecific' => {
        type_name: FIRST_AVAILABLE_USE_UNAVAILABLE_INFRASUBSPECIFIC,
        type_label: 'First available use of; unavailable (infrasubspecific) name',
        ranks: SPECIES_GROUP_LABEL,

        group_order: 12,

        templates: {
          default: {
            content: '[First available use of {taxac %<object_taxon_id>i}; unavailable (infrasubspecific) name%<citation>s.]',
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
      ALSO_DESCRIBED_AS_NEW = 'AlsoDescribedAsNew' => {
        type_name: ALSO_DESCRIBED_AS_NEW,
        type_label: 'Also described as new',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 14,
        group_key: ->(o) { [o.type] },

        templates: {
          default: {
            content: '[Also described as new by %<grouped_item_taxts>s.]'
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:reference, :pages]
      },
      EMENDATION = 'Emendation' => {
        type_name: EMENDATION,
        type_label: 'Emendation (justified, unjustified, or deemed justified by prevailing usage)',
        ranks: ANY_RANK_GROUP_LABEL,

        # Next to the misspellings: both are subsequent spellings (Art. 33.1).
        group_order: 15,
        # One line per kind and emended spelling (`text_value`, e.g. "<i>binghamii</i>").
        group_key: ->(o) { [o.type, 'subtype', o.subtype, 'text_value', o.text_value, 'object_taxon_id', o.object_taxon_id] },

        templates: {
          default: {
            content: '[%<lead>s by %<grouped_item_taxts>s.]',
            vars: ->(o) {
              {
                # Validation requires a known subtype; the fallback only keeps an unsaved, invalid item renderable.
                lead: format(
                  EMENDATION_LEADS.fetch(o.subtype.to_s, '%<spelling>s'),
                  spelling: o.text_value,
                  object_taxon_id: o.object_taxon_id.to_i
                )
              }
            }
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        subtypes: EMENDATION_SUBTYPES = [
          EMENDATION_JUSTIFIED = 'Justified',
          EMENDATION_UNJUSTIFIED = 'Unjustified',
          EMENDATION_DEEMED_JUSTIFIED = 'DeemedJustified'
        ],
        subtype_options: [
          ['Justified (Arts. 32.5, 33.2.2)', EMENDATION_JUSTIFIED],
          ['Unjustified (Art. 33.2.3)', EMENDATION_UNJUSTIFIED],
          ['Unjustified, deemed justified by prevailing usage (Art. 33.2.3.1)', EMENDATION_DEEMED_JUSTIFIED]
        ],

        # The emendation's own record (status "unjustified emendation"): required for Unjustified, absent otherwise
        # (HistoryItem#validate_emendation_object_taxon).
        optional_attributes: [:object_taxon],
        validates_presence_of: [:subtype, :text_value, :reference, :pages]
      },
      MISSPELLED_AS = 'MisspelledAs' => {
        type_name: MISSPELLED_AS,
        type_label: 'Misspelled as',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 16,
        # One line per misspelt spelling (`text_value`, e.g. "<i>atrata</i>").
        group_key: ->(o) { [o.type, 'text_value', o.text_value] },

        templates: {
          default: {
            content: '[Misspelled as {misspelling %<spelling>s} by %<grouped_item_taxts>s.]',
            vars: ->(o) { { spelling: o.text_value } }
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:text_value, :reference, :pages]
      },
      INCERTAE_SEDIS_IN = 'IncertaeSedisIn' => {
        type_name: INCERTAE_SEDIS_IN,
        type_label: 'Incertae sedis in (and unidentifiable)',
        ranks: ANY_RANK_GROUP_LABEL,

        # After the status lines (canonical order: unidentifiable / incertae sedis).
        group_order: 65,
        group_key: ->(o) { [o.type, 'subtype', o.subtype, 'object_taxon_id', o.object_taxon_id] },

        templates: {
          default: {
            content: '%<prefix>s in {tax %<object_taxon_id>i}: %<grouped_item_taxts>s.',
            vars: ->(o) {
              {
                # Validation requires a known subtype; the fallback only keeps an unsaved, invalid item renderable.
                prefix: INCERTAE_SEDIS_IN_PREFIXES.fetch(o.subtype.to_s, INCERTAE_SEDIS_IN_PREFIXES['IncertaeSedis']),
                object_taxon_id: o.object_taxon_id
              }
            }
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        subtypes: INCERTAE_SEDIS_IN_SUBTYPES = [
          INCERTAE_SEDIS = 'IncertaeSedis',
          UNIDENTIFIABLE_TAXON = 'UnidentifiableTaxon',
          UNIDENTIFIABLE_TO_GENUS = 'UnidentifiableToGenus'
        ],
        subtype_options: [
          ['Incertae sedis in', INCERTAE_SEDIS],
          ['Unidentifiable taxon; incertae sedis in', UNIDENTIFIABLE_TAXON],
          ['Unidentifiable to genus; incertae sedis in', UNIDENTIFIABLE_TO_GENUS]
        ],

        validates_presence_of: [:subtype, :object_taxon, :reference, :pages]
      },
      MATERIAL_REFERRED_TO = 'MaterialReferredTo' => {
        type_name: MATERIAL_REFERRED_TO,
        type_label: 'Material referred to',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 110,
        group_key: ->(o) { [o.type, 'object_taxon_id', o.object_taxon_id] },

        templates: {
          default: {
            content: 'Material referred to {tax %<object_taxon_id>i} by %<grouped_item_taxts>s.',
            vars: ->(o) { { object_taxon_id: o.object_taxon_id } }
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:object_taxon, :reference, :pages]
      },
      MATERIAL_OF_UNAVAILABLE_NAME_REFERRED_HERE = 'MaterialOfUnavailableNameReferredHere' => {
        type_name: MATERIAL_OF_UNAVAILABLE_NAME_REFERRED_HERE,
        type_label: 'Material of the unavailable name referred here',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 111,
        group_key: ->(o) { [o.type, 'object_taxon_id', o.object_taxon_id] },

        templates: {
          default: {
            content: 'Material of the unavailable name {tax %<object_taxon_id>i} referred here by %<grouped_item_taxts>s.',
            vars: ->(o) { { object_taxon_id: o.object_taxon_id } }
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:object_taxon, :reference, :pages]
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
                  trailer_types = [
                    JUNIOR_PRIMARY_HOMONYM_OF,
                    JUNIOR_SECONDARY_HOMONYM_OF,
                    JUNIOR_PRIMARY_HOMONYM_OF_HARDCODED_GENUS
                  ]
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
      },
      PLACEMENT_IN = 'PlacementIn' => {
        type_name: PLACEMENT_IN,
        type_label: 'Placement in (genus- and family-group: "X in A, B: ...")',
        ranks: GENUS_GROUP_LABEL,

        group_order: 80,
        # The placement ("{tax A}, {tax B}", "{tax A}, {tax B}, {tax C} genus group") is taxt in `taxt`;
        # one line per placement.
        group_key: ->(o) { [o.type, 'taxt', o.taxt, o.force_author_citation?] },

        templates: {
          default: {
            content: '%<subject>s in %<placement>s: %<grouped_item_taxts>s.',
            vars: ->(o) { { subject: HIGHER_NAME_SUBJECT.call(o), placement: o.taxt } }
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:taxt, :reference, :pages],
        allow_force_author_citation: true
      },
      PLACEMENT_INCERTAE_SEDIS_IN = 'PlacementIncertaeSedisIn' => {
        type_name: PLACEMENT_INCERTAE_SEDIS_IN,
        type_label: 'Incertae sedis in (genus- and family-group: "X incertae sedis in A: ...")',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 81,
        group_key: ->(o) { [o.type, 'object_taxon_id', o.object_taxon_id, o.force_author_citation?] },

        templates: {
          default: {
            content: '%<subject>s <i>incertae sedis</i> in {tax %<object_taxon_id>s}: %<grouped_item_taxts>s.',
            vars: ->(o) { { subject: HIGHER_NAME_SUBJECT.call(o), object_taxon_id: o.object_taxon_id } }
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:object_taxon, :reference, :pages],
        allow_force_author_citation: true
      },
      AS_GENUS = 'AsGenus' => {
        type_name: AS_GENUS,
        type_label: 'As genus ("X as genus: ...")',
        ranks: GENUS_GROUP_LABEL,

        group_order: 82,
        group_key: ->(o) { [o.type, o.force_author_citation?] },

        templates: {
          default: {
            content: '%<subject>s as genus: %<grouped_item_taxts>s.',
            vars: ->(o) { { subject: HIGHER_NAME_SUBJECT.call(o) } }
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        validates_presence_of: [:reference, :pages],
        allow_force_author_citation: true
      },
      AS_RANK_OF = 'AsRankOf' => {
        type_name: AS_RANK_OF,
        type_label: 'As subgenus/tribe/subtribe/subfamily of ("X as subgenus of A: ...")',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 83,
        group_key: ->(o) { [o.type, 'subtype', o.subtype, 'object_taxon_id', o.object_taxon_id, o.force_author_citation?] },

        templates: {
          default: {
            content: '%<subject>s as %<rank>s of {tax %<object_taxon_id>s}: %<grouped_item_taxts>s.',
            vars: ->(o) {
              {
                subject: HIGHER_NAME_SUBJECT.call(o),
                # Validation requires a known subtype; the fallback only keeps an unsaved, invalid item renderable.
                rank: AS_RANK_OF_RANKS.fetch(o.subtype.to_s, '?'),
                object_taxon_id: o.object_taxon_id
              }
            }
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        subtypes: AS_RANK_OF_SUBTYPES = AS_RANK_OF_RANKS.keys,
        subtype_options: AS_RANK_OF_RANKS.map { |subtype, rank| ["As #{rank} of", subtype] },

        validates_presence_of: [:subtype, :object_taxon, :reference, :pages],
        allow_force_author_citation: true
      },
      AS_SYNONYM_OF = 'AsSynonymOf' => {
        type_name: AS_SYNONYM_OF,
        type_label: 'As junior/senior synonym of (genus- and family-group: "X as junior synonym of A: ...")',
        ranks: ANY_RANK_GROUP_LABEL,

        group_order: 84,
        group_key: ->(o) { [o.type, 'subtype', o.subtype, 'object_taxon_id', o.object_taxon_id, o.force_author_citation?] },

        templates: {
          default: {
            content: '%<subject>s as %<kind>s synonym of {tax %<object_taxon_id>s}: %<grouped_item_taxts>s.',
            vars: ->(o) {
              {
                subject: HIGHER_NAME_SUBJECT.call(o),
                # Validation requires a known subtype; the fallback only keeps an unsaved, invalid item renderable.
                kind: AS_SYNONYM_OF_KINDS.fetch(o.subtype.to_s, '?'),
                object_taxon_id: o.object_taxon_id
              }
            }
          }
        },

        groupable_template_content: '%<citation>s',
        groupable_template_vars: ->(o) { { citation: o.citation } },

        subtypes: AS_SYNONYM_OF_SUBTYPES = AS_SYNONYM_OF_KINDS.keys,
        subtype_options: AS_SYNONYM_OF_KINDS.map { |subtype, kind| ["As #{kind} synonym of", subtype] },

        validates_presence_of: [:subtype, :object_taxon, :reference, :pages],
        allow_force_author_citation: true
      }
    }

    TYPES = TYPE_DEFINITIONS.keys
    VISIBLE_AS_OBJECT = [
      JUNIOR_SYNONYM_OF
    ]
  end
end
