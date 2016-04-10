class HolLiterature < ActiveRecord::Base
  attr_accessible :tnuid,
                  :pub_id,
                  :taxon,
                  :name,
                  :describer,
                  :rank,
                  :year,
                  :month,
                  :comments,
                  :full_pdf,
                  :pages,
                  :public,
                  :author

end
