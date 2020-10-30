# frozen_string_literal: true

module DatabaseScripts
  class TaxaWithSameName < DatabaseScript
    # Manually checked in October 2020.
    # Via:
    # DatabaseScripts::TaxaWithSameName.new.results.pluck(:id).in_groups_of(10).each { |g| puts g.join(', ') }; nil
    CHECKED_TAXON_IDS = [
      510404, 458152, 430314, 430315, 430462, 430463, 429174, 429947, 508872, 430835,
      430836, 430852, 430853, 430913, 430914, 431037, 508183, 431136, 431137, 431214,
      509451, 431140, 510501, 431262, 431263, 442816, 442817, 431851, 431852, 429365,
      429366, 432028, 432029, 432054, 432055, 432079, 432080, 432222, 432223, 432224,
      509511, 432468, 508825, 432510, 432531, 432533, 432573, 432574, 508874, 432706,
      432783, 432784, 432784, 432784, 509429, 432795, 432922, 432921, 432922, 433089,
      433090, 433126, 433127, 433272, 433274, 433275, 433364, 507132, 433371, 433372,
      433387, 507184, 433399, 433400, 433447, 433448, 433506, 433507, 433508, 433533,
      433534, 433575, 433576, 433614, 433615, 433657, 433658, 433675, 433676, 507602,
      433726, 509362, 433750, 434010, 434009, 434062, 434063, 434229, 434230, 434244,
      434245, 434268, 462040, 434274, 462049, 434299, 508344, 434323, 434324, 434325,
      462065, 434332, 434333, 434930, 434931, 434932, 508831, 481599, 434971, 434973,
      434979, 434980, 435018, 435018, 435019, 435044, 435045, 507352, 507369, 435217,
      435218, 435267, 435268, 435276, 435275, 435338, 435339, 435671, 435672, 435808,
      435809, 436719, 436720, 436888, 436889, 436927, 436928, 436958, 508731, 437037,
      437038, 437078, 437079, 461786, 461786, 509587, 509587, 509587, 437300, 508619,
      510327, 509434, 437311, 509483, 437327, 509365, 509366, 437341, 509392, 437349,
      437350, 508744, 510357, 509592, 458393, 456756, 508743, 509369, 456758, 459422,
      509583, 509510, 456781, 459665, 510351, 509370, 437453, 508826, 456681, 509502,
      437462, 509421, 509503, 437463, 509445, 437471, 509361, 437493, 507620, 456799,
      437495, 437496, 510322, 510343, 509428, 509394, 437515, 437531, 509439, 437567,
      509372, 456612, 508616, 508618, 437580, 510390, 437596, 509478, 509580, 458416,
      509440, 456828, 437630, 509375, 437639, 507673, 458054, 508617, 508835, 437643,
      508240, 509376, 457522, 495852, 437657, 509377, 509479, 437667, 456850, 509378,
      456852, 507928, 509441, 437690, 437691, 509476, 437699, 437705, 509379, 456857,
      509380, 456861, 509382, 457249, 461985, 437745, 437746, 437746, 509323, 458098,
      437756, 509384, 509385, 437757, 509442, 437759, 509386, 509387, 437837, 456890,
      509443, 509420, 509579, 437863, 437998, 437999, 438097, 438098, 429670, 430003,
      429429, 429503, 438359, 438360, 438399, 438400, 509474, 438651, 509475, 457549,
      438749, 438750, 438877, 508870, 439347, 439348, 510353, 458806, 510354, 458811,
      457377, 510355, 460778, 510406, 439635, 439636, 507441, 457292, 457292, 457305,
      508019, 507479, 508190, 430018, 430048, 510326, 439748, 439937, 439938, 440186,
      440187, 440203, 440204, 440232, 508024, 429683, 429684, 440303, 440304, 440307,
      440308, 440323, 440324, 440346, 440347, 440358, 440359, 509095, 440564, 440614,
      440615, 440705, 440706, 440890, 440891, 440932, 440933, 440971, 440972, 441028,
      509407, 507668, 509469, 441400, 509447, 441505, 509403, 441626, 441627, 441524,
      509404, 441555, 509448, 509448, 459485, 510349, 441611, 509430, 441617, 441618,
      429026, 429029, 429216, 429217, 508021, 456561, 442598, 509319, 442614, 442615,
      429235, 429236, 442795, 442796, 509219, 509507, 442960, 442961, 509131, 509131,
      461981, 461981, 509406, 509563, 443094, 510409, 443107, 443108, 443115, 443117,
      443119, 429027, 430193, 510208, 507799, 507799, 442931, 442932, 443571, 443572,
      443647, 443646, 443934, 443935, 443936, 443972, 443973, 443985, 443986, 443987,
      443988, 444031, 444032, 444036, 444037, 444038, 444039, 444040, 444040, 444098,
      509581, 444284, 444285, 444310, 444311, 510387, 444442, 444602, 444603, 444616,
      444617, 509393, 457328, 509230, 444935, 444937, 444938, 510361, 445180, 445357,
      445358, 445377, 445378, 445431, 445432, 445470, 445471, 445532, 445533, 445569,
      445570, 445574, 445575, 445647, 445648, 445761, 445762, 445777, 445778, 445857,
      445858, 445888, 445889, 445980, 445981, 510331, 446341, 459099, 509488, 459112,
      509492, 459125, 509335, 457882, 509600, 509527, 457883, 457474, 509528, 510324,
      457905, 509425, 457910, 509426, 446382, 457520, 509444, 509468, 509553, 457786,
      509427, 457942, 509423, 457459, 510335, 458294, 459298, 509569, 457765, 509571,
      509424, 457464, 430032, 430036, 446884, 446885, 459707, 510342, 459795, 510358,
      459818, 510359, 510344, 459897, 446959, 446960, 446976, 446977, 447022, 447024,
      447067, 509632, 509633, 447164, 446967, 446968, 447202, 447203, 509477, 447258,
      447350, 447351, 447705, 447706, 447812, 509594, 447787, 447788, 447798, 447799,
      447891, 447892, 447893, 448533, 448534, 448556, 448557, 448650, 448651, 448776,
      448777, 449193, 449194, 449192, 449197, 449198, 449248, 449249, 449268, 449269,
      449310, 449311, 449439, 449440, 449529, 449530, 449689, 449690, 449691, 449692,
      461983, 507773, 449769, 461925, 449795, 449803, 449804, 449805, 449985, 449986,
      507637, 507637, 507637, 449988, 461923, 450000, 507772, 450020, 461924, 450021,
      450065, 450066, 450136, 450135, 450145, 461368, 450191, 450192, 450192, 450283,
      450284, 507633, 450326, 507633, 450326, 450497, 450498, 450510, 461982, 450532,
      450533, 450598, 450599, 450697, 461984, 450721, 450722, 510356, 450725, 450790,
      450791, 451171, 451172, 461384, 509590
    ]

    def results
      same_name = Taxon.joins(:name).group('names.name').having('COUNT(*) > 1')

      Taxon.joins(:name).where(names: { name: same_name.select(:name) }).
        order('names.name').
        includes(protonym: { authorship: { reference: :author_names } }).references(:reference_author_names)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Authorship', 'Rank', 'Status', 'Manually checked (October 2020)'
        t.rows do |taxon|
          [
            taxon_link(taxon),
            taxon.authorship_reference.key_with_suffixed_year,
            taxon.type,
            taxon.status,
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
