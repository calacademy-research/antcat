# coding: UTF-8
class AddMissingDubovikovs < ActiveRecord::Migration

  def up
    b = Bolton::Reference.find_by_authors_and_citation_year 'Dubovikov, D.A.', '2005'
    b.update_attribute :citation_year, '2005a'

    b = Bolton::Reference.create! authors: 'Dubovikov, D.A.', citation_year: '2005b',
      title: 'A new species of the genus Proformica Ruzsky, 1902 from North Ossetia and key to the identification of Proformica species of the Caucasian Isthmus',
      journal: 'Caucasian Entomological Bulletin [Kavkazskii Entomolicheskii Byulleten’]',
      series_volume_issue: '1',
      pagination: '189-191',
      reference_type: 'ArticleReference',
      original: 
%{Dubovikov, D.A. 2005b. A new species of the genus Proformica Ruzsky, 1902 from North Ossetia and key to the identification of Proformica species of the Caucasian Isthmus. Caucasian Entomological Bulletin [Kavkazskii Entomolicheskii Byulleten’] 1: 189-191.}
    raise unless b.valid?

    Bolton::Reference.reindex
  end

  def down
  end
end
