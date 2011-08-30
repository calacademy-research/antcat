class FixAccentsInPdfNames2 < ActiveRecord::Migration
  def self.up
    [
      [
      "http://antcat.org/documents/4179/Hosoishi & Ogata 2009 [A check list of the ant genus Crematogaster in Asia.pdf",
      "http://antcat.org/documents/4179/Hosoishi Ogata 2009 A check list of the ant genus Crematogaster in Asia.pdf",
      ],

      [
      "http://antcat.org/documents/4216/Xu et al. 1998 [Seven species of the ant genus Pheidole Westwood newly recorded in China (Hymenoptera Formicidae). [In Chinese.PDF",
      "http://antcat.org/documents/4216/Xu et al. 1998 Seven species of the ant genus Pheidole Westwood newly recorded in China (Hymenoptera Formicidae). In Chinese.PDF",
      ],

      [
      "http://antcat.org/documents/4217/Xu et al. 1998 [Three Ponerinae species newly recorded in China and new distribution of Ponera sinensis (Hymenoptera Formicidae). [In Chinese.PDF",
      "http://antcat.org/documents/4217/Xu et al. 1998 Three Ponerinae species newly recorded in China and new distribution of Ponera sinensis (Hymenoptera Formicidae). In Chinese.PDF",
      ],

      [
      "http://antcat.org/documents/4827/Keller_&_Reeve_1994_Evolution [Genetic variability, queen number, and polyandry in social Hymenoptera.pdf",
      "http://antcat.org/documents/4827/Keller_Reeve_1994_Evolution Genetic variability, queen number, and polyandry in social Hymenoptera.pdf",
      ],

      [
      "http://antcat.org/documents/4828/Gobin_et_al_2006_Cell_Tissue_Res [Queen-worker spermatheca differences.pdf",
      "http://antcat.org/documents/4828/Gobin_et_al_2006_Cell_Tissue_Res Queen-worker spermatheca differences.pdf",
      ],

      [
      "http://antcat.org/documents/4829/Gobin_et_al_2008_Naturwissenschaften [Degeneration of spermatheca in worker ants.pdf",
      "http://antcat.org/documents/4829/Gobin_et_al_2008_Naturwissenschaften Degeneration of spermatheca in worker ants.pdf",
      ],

      [
      "http://antcat.org/documents/4830/Ito_et_al_2010_Naturwissenschaften [Thelytoky in Pyramica membranifera.pdf",
      "http://antcat.org/documents/4830/Ito_et_al_2010_Naturwissenschaften Thelytoky in Pyramica membranifera.pdf",
      ],

    ].each do |original, fix|
      ActiveRecord::Base.connection.execute %{UPDATE reference_documents SET url = "#{fix}" WHERE url = "#{original}"}
      file_file_name_original = original[(original.rindex('/')+1)..-1]
      file_file_name_fix = fix[(fix.rindex('/')+1)..-1]
      ActiveRecord::Base.connection.execute %{UPDATE reference_documents SET file_file_name = "#{file_file_name_fix}" WHERE file_file_name = "#{file_file_name_original}"}
    end

  end

  def self.down
  end
end
