# coding: UTF-8

desc "Reset Formicidae's taxonomic history"
task :reset_hist => :environment do
  Family.first.taxonomic_history_items.first.update_attribute :taxt, %{Formicidae as family: {ref 126798}: 124 [Formicariae]; {ref 126849}: 147 [Formicarides]; {ref 129018}: 356 [first spelling as Formicidae]; {ref 125734}: 331; {ref 129811}: 217; {ref 129098}: 171; {ref 127561}: 877; {ref 124947}: 1 [Formicariae]; {ref 127185}: 275 [Formicina]; {ref 128683}: 52; {ref 128685}: 1; {ref 127189}: 21; {ref 127193}: 6; {ref 125819}: 6 [Formicaria]; {ref 124987}: 307 [Formicinae]; {ref 124988}: 19 [Formicariae]; {ref 133039}: 1; {ref 133007}: 1; {ref 128175}: 5 [Formicarii]; {ref 122766}: 1; {ref 128184}: 91 [Formicariae or Formicidae]; {ref 122385}: 384; all subsequent authors}
end

