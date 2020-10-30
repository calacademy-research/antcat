# frozen_string_literal: true

module DatabaseScripts
  class TaxaWithSameNameAndStatus < DatabaseScript
    # Manually checked in October 2020.
    # Via:
    # DatabaseScripts::TaxaWithSameNameAndStatus.new.results.pluck(:id).in_groups_of(10).each { |g| puts g.join(', ') }; nil
    CHECKED_TAXON_IDS = [
      510404, 458152, 430835, 430836, 508872, 430913, 430914, 432921, 432922, 433272,
      433274, 433275, 433657, 433658, 434062, 434063, 462065, 434323, 434324, 434325,
      434930, 434931, 434932, 481599, 508831, 434971, 434973, 434979, 434980, 435018,
      435019, 435044, 435045, 510327, 509434, 509365, 509366, 508744, 509392, 510357,
      458393, 508743, 456756, 509369, 456758, 459422, 509583, 509510, 456781, 510351,
      459665, 508826, 456681, 509421, 509503, 437463, 507620, 456799, 510322, 510343,
      509428, 508616, 508618, 456612, 437580, 510390, 458416, 509580, 509440, 456828,
      508617, 458054, 508240, 508835, 509376, 509378, 456850, 509441, 456852, 509380,
      456857, 509382, 456861, 457249, 461985, 437745, 437746, 458098, 509323, 509384,
      509385, 456890, 509443, 509420, 509579, 437998, 437999, 429429, 429503, 457549,
      509475, 510353, 458806, 510354, 458811, 457377, 510355, 460778, 510406, 440186,
      440187, 440232, 508024, 429683, 429684, 440932, 440933, 440971, 440972, 441626,
      441627, 510349, 459485, 508021, 456561, 442795, 442796, 509219, 509507, 442960,
      442961, 509406, 509563, 442931, 442932, 443934, 443935, 443936, 443987, 443988,
      444036, 444037, 444038, 509393, 457328, 509488, 459099, 509492, 459112, 509335,
      459125, 457883, 509527, 457474, 509528, 510324, 457905, 509425, 457910, 457520,
      509444, 509468, 457786, 509553, 509427, 457942, 509423, 457459, 510335, 458294,
      509569, 459298, 457765, 509571, 509424, 457464, 446884, 446885, 510342, 459707,
      510358, 459795, 459818, 510359, 459897, 510344, 446959, 446960, 447067, 509632,
      447164, 509633, 446967, 446968, 447891, 447892, 447893, 449192, 449193, 449194,
      449268, 449269, 449689, 449690, 450497, 450498, 450532, 450533, 450790, 450791
    ]

    def results
      name_and_status = Taxon.joins(:name).group('names.name, status').having('COUNT(*) > 1')

      Taxon.joins(:name).
        where(names: { name: name_and_status.select(:name) }, status: name_and_status.select(:status)).
        order('names.name').
        includes(protonym: { authorship: :reference })
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Authorship', 'Rank', 'Status', 'Unresolved homonym?', 'Manually checked (October 2020)'
        t.rows do |taxon|
          [
            taxon_link(taxon),
            taxon.authorship_reference.key_with_suffixed_year,
            taxon.type,
            taxon.status,
            ('Yes' if taxon.unresolved_homonym?),
            ('Yes' if taxon.id.in?(CHECKED_TAXON_IDS))
          ]
        end
      end
    end
  end
end

__END__

section: list
category: Catalog
tags: []

related_scripts:
  - SameNamedPassThroughNames
  - TaxaWithSameName
  - TaxaWithSameNameAndStatus
  - ProtonymsWithSameName
