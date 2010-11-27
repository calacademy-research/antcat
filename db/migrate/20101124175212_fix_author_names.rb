require Rails.root + 'spec/support/factories'

class FixAuthorNames < ActiveRecord::Migration
  def self.up
    AuthorName.transaction do

      AuthorName.correct "Diehl-Flieg, E.", "Diehl-Fleig, E."
      AuthorName.alias true, "Diehl, E.", "Diehl-Fleig, E."

      son = Factory :author_name, :name => 'Diehl-Fleig, Ed.'
      AuthorName.alias true, "Diehl-Fleig, E. D.", "Diehl-Fleig, Ed."
      ['96-1373', '96-0213'].each do |cite_code|
        reference = Reference.find_by_cite_code cite_code
        reference_author_name_for_son = ReferenceAuthorName.first(
          :conditions => ['reference_id = ? AND position = ?', reference.id, 2])
        reference_author_name_for_son.update_attribute :author_name, son
        reference.update_author_names_string
      end

      AuthorName.alias true, "Cammel, M.", "Cammell, M.", "Cammell, M. E."
      AuthorName.alias true, "Roy Chowdhury, S.", "Roychowdhury, S."
      AuthorName.alias true, "Zorrilla, J.", "Zorilla, J. M.", "Zorrilla, J. M."
      AuthorName.alias true, "Diaz Bitancourt, M. E.", "Díaz-Betancourt, M. E."
      AuthorName.alias true, "Don, A. W.", "Don, W."
      AuthorName.alias true, "Dubovikoff, D. A.", "Dubovikov, D. A."
      AuthorName.alias true, "Franch Batlle, J.", "Franch, J."
      AuthorName.alias true, "Martínez Ibáñez, M. D.", "Martínez-Ibañez, D.", "Martínez-Ibáñez, M. D.", "Martínez, M. D."
      AuthorName.alias true, 'Mustak Ali, T. M.', 'Musthak Ali, T. M.'
      AuthorName.alias true, 'Reyes López, J.', 'Reyes López, J. L.', 'Reyes, J.', 'Reyes, J. L.'
      AuthorName.alias true, "Zhigul'skaya, Z. A.", 'Zhigulskaya, Z. A.'
      AuthorName.alias true, 'Delabie, J.', 'Delabie, J. C.', 'Delabie, J. H.', 'Delabie, J. H. C.'
      AuthorName.alias true, 'MacKay, E.', 'MacKay, E. E.', 'MacKay, E. S.'
      AuthorName.alias true, 'Williams, D.', 'Williams, D. F.'
      AuthorName.alias true, 'Carpintero Ortega, S.', 'Carpintero, S.'
      AuthorName.alias true, 'Covarrubias Berríos, R.', 'Covarrubias, R.'
      AuthorName.alias true, 'Dazzini Valcurone, M.', 'Dazzini, M. V.'
      AuthorName.alias true, 'González-Villarreal, D.', 'Gonzalez, D.'
      AuthorName.alias true, 'Hernández Triana, L. M.', 'Hernández, L. M.'
      AuthorName.alias true, 'Jiménez Rojas, J.', 'Jiménez, J. J.'
      AuthorName.alias true, 'Riasol Boixart, J. M.', 'Riasol, J. M.'
      AuthorName.alias true, 'Schlick-Steiner, B. C.', 'Schlick, B.'
      AuthorName.alias true, 'Serna Cardona, F. J.', 'Serna, F.', 'Serna, F. J.'
      AuthorName.alias true, 'Serrano Talavera, J. M.', 'Serrano, J. M.'
      AuthorName.alias true, 'Suñer i Escriche, D.', 'Suñer, D.'
      AuthorName.alias true, 'Valenzuela-González, J.', 'Valenzuela, J.'
      AuthorName.alias true, 'Varvio-Aho, S.-L.', 'Varvio, S. L.'
      AuthorName.alias true, 'Carvalho, A. O. R.', 'Carvalho, A. O. R. de'
      AuthorName.alias true, 'Feitosa, R. do', 'Feitosa, R. M.'
      AuthorName.alias true, 'Fonseca, C. R. F.', 'Fonseca, C. R. V. da'
      AuthorName.alias true, 'Mariano, C. d. S. F.', 'Mariano, C. S. F.'
      AuthorName.alias true, 'Moretti, T. C.', 'Moretti, T. de C.'
      AuthorName.alias true, 'Nascimento, I. C.', 'Nascimento, I. C. do'
      AuthorName.alias true, 'Pompolo, S. d. G.', 'Pompolo, S. G.'
      AuthorName.alias true, 'Queiroz, M. V. B.', 'Queiroz, M. V. B. de'
      AuthorName.alias true, 'Ramos Lacau, L. de S.', 'Ramos, L. S.'
      AuthorName.alias true, "Darlington, P. J.", "Darlington, P. J., Jr."
      AuthorName.alias true, "Davis, L. R.", "Davis, L. R., Jr."
      AuthorName.alias true, "Jones, J. W.", "Jones, J. W., Jr."
      AuthorName.alias true, "Page, R. E.", "Page, R. E., Jr."
      AuthorName.alias true, "Poinar, G.", "Poinar, G., Jr."
      AuthorName.alias true, "Regnier, F. E.", "Regnier, F. E., Jr."
      AuthorName.alias true, "La Berge, W. E.", "LaBerge, W. E."
      AuthorName.alias true, "Alonso, L.", "Alonso, L. E."
      AuthorName.alias true, "Alpert, G.", "Alpert, G. D."
      AuthorName.alias true, "Andersen, A.", "Andersen, A. N."
      AuthorName.alias true, "Barlin, M.", "Barlin, M. R."
      AuthorName.alias true, "Bequaert, J.", "Bequaert, J. C."
      AuthorName.alias true, "Bhatkar, A.", "Bhatkar, A. P."
      AuthorName.alias true, "Billen, J.", "Billen, J. P. J."
      AuthorName.alias true, "Blum, M.", "Blum, M. S."
      AuthorName.alias true, "Boieiro, M.", "Boieiro, M. R. C."
      AuthorName.alias true, "Bond, W.", "Bond, W. J."
      AuthorName.alias true, "Boting, P.", "Boting, P. H."
      AuthorName.alias true, "Brühl, C.", "Brühl, C. A."
      AuthorName.alias true, "Carlin, N.", "Carlin, N. F."
      AuthorName.alias true, "Carlysle, T.", "Carlysle, T. C."
      AuthorName.alias true, "Chao, J.", "Chao, J.-T."
      AuthorName.alias true, "Chown, S.", "Chown, S. L."
      AuthorName.alias true, "Collingwood, C.", "Collingwood, C. A."
      AuthorName.alias true, "Cover, S.", "Cover, S. P."
      AuthorName.alias true, "Crozier, R.", "Crozier, R. H."
      AuthorName.alias true, "Cuezzo, F.", "Cuezzo, F. C."
      AuthorName.alias true, "Dijkstra, P.", "Dijkstra, P. J."
      AuthorName.alias true, "Dlussky, G.", "Dlussky, G. M."
      AuthorName.alias true, "Fadl, H.", "Fadl, H. H."
      AuthorName.alias true, "Fernandez Escudero, I.", "Fernandez-Escudero"
      AuthorName.alias true, "Garcia Perez, J.", "García-Pérez, J. A."
      AuthorName.alias true, "Gauld, I.", "Gauld, I. D."
      AuthorName.alias true, "Gertsch, P.", "Gertsch, P. J."
      AuthorName.alias true, "Greenslade, P.", "Greenslade, P. J. M."
      AuthorName.alias true, "Grimaldi, D.", "Grimaldi, D. A."
      AuthorName.alias true, "Guralnick, M.", "Guralnick, M. W."
      AuthorName.alias true, "Hansen, L.", "Hansen, L. D."
      AuthorName.alias true, "Heterick, B.", "Heterick, B. E."
      AuthorName.alias true, "Holway, D.", "Holway, D. A."
      AuthorName.alias true, "Hong, Y.", "Hong, Y.-C."
      AuthorName.alias true, "Huang, J.", "Huang, J.-H."
      AuthorName.alias true, "Huxley, J.", "Huxley, J. S."
      AuthorName.alias true, "Imai, H.", "Imai, H. T."
      AuthorName.alias true, "Keller, R.", "Keller, R. A."
      AuthorName.alias true, "King, J.", "King, J. R."
      AuthorName.alias true, "Klotz, J.", "Klotz, J. H."
      AuthorName.alias true, "Kohout, R.", "Kohout, R. J."
      AuthorName.alias true, "Lattke, J.", "Lattke, J. E."
      AuthorName.alias true, "LePrince, D.", "LePrince, D. J."
      AuthorName.alias true, "Liu, M.", "Liu, M.-T."
      AuthorName.alias true, "Lubin, Y.", "Lubin, Y. D."
      AuthorName.alias true, "Lyu, D.", "Lyu, D.-P."
      AuthorName.alias true, "MacKay, W.", "MacKay, W. P."
      AuthorName.alias true, "Majer, J.", "Majer, J. D."
      AuthorName.alias true, "McDonald, J.", "McDonald, J. A."
      AuthorName.alias true, "McKey, D.", "McKey, D. B."
      AuthorName.alias true, "Morales, M.", "Morales, M. A."
      AuthorName.alias true, "Muesebeck, C. F.", "Muesebeck, C. F. W."
      AuthorName.alias true, "Nadkarni, N.", "Nadkarni, N. M."
      AuthorName.alias true, "Oldroyd, B.", "Oldroyd, B. P."
      AuthorName.alias true, "Pacheco, J.", "Pacheco, J. A."
      AuthorName.alias true, "Palacio, E.", "Palacio, E. E."
      AuthorName.alias true, "Parr, C.", "Parr, C. L."
      AuthorName.alias true, "Pedersen, J.", "Pedersen, J. S."
      AuthorName.alias true, "Peeters, C.", "Peeters, C. P."
      AuthorName.alias true, "Perrault, G.", "Perrault, G. H."
      AuthorName.alias true, "Petrov, I.", "Petrov, I. Z."
      AuthorName.alias true, "Plaza, J.", "Plaza, J. L."
      AuthorName.alias true, "Porter, S.", "Porter, S. D."
      AuthorName.alias true, "Prince, A.", "Prince, A. J."
      AuthorName.alias true, "Prins, A.", "Prins, A. J."
      AuthorName.alias true, "Prusak, Z.", "Prusak, Z. A."
      AuthorName.alias true, "Quirán, E.", "Quiran, E. M."
      AuthorName.alias true, "Quiroz-Robledo, L.", "Quiroz-Robledo, L. N."
      AuthorName.alias true, "Radchenko, A.", "Radchenko, A. G."
      AuthorName.alias true, "Reimer, N.", "Reimer, N. J."
      AuthorName.alias true, "Robson, S. K.", "Robson, S. K. A."
      AuthorName.alias true, "Rust, M.", "Rust, M. K."
      AuthorName.alias true, "Sadil, J.", "Sadil, J. V."
      AuthorName.alias true, "Schmidt, G.", "Schmidt, G. H."
      AuthorName.alias true, "Schneider, L.", "Schneider, L. C."
      AuthorName.alias true, "Schultz, T.", "Schultz, T. R."
      AuthorName.alias true, "Shattuck, S.", "Shattuck, S. O."
      AuthorName.alias true, "Shoemaker, D.", "Shoemaker, D. D."
      AuthorName.alias true, "Silva, R. R.", "Silva, R. R. da"
      AuthorName.alias true, "Singh, T.", "Singh, T. K."
      AuthorName.alias true, "Soyunov, O.", "Soyunov, O. S."
      AuthorName.alias true, "Stankiewicz, A.", "Stankiewicz, A. M."
      AuthorName.alias true, "Steiner, F.", "Steiner, F. M."
      AuthorName.alias true, "Stuart, R.", "Stuart, R. J."
      AuthorName.alias true, "Townes, H.", "Townes, H. K."
      AuthorName.alias true, "Trager, J.", "Trager, J. C."
      AuthorName.alias true, "Turnbull, C.", "Turnbull, C. L."
      AuthorName.alias true, "Umphrey, G.", "Umphrey, G. J."
      AuthorName.alias true, "Vail, K.", "Vail, K. M."
      AuthorName.alias true, "Vick, K.", "Vick, K. W."
      AuthorName.alias true, "Vilhelmsen, L.", "Vilhelmsen, L. B."
      AuthorName.alias true, "Villet, M.", "Villet, M. H."
      AuthorName.alias true, "Wang, M.", "Wang, M.-S."
      AuthorName.alias true, "Wheeler, D.", "Wheeler, D. E."
      AuthorName.alias true, "Wojcik, D.", "Wojcik, D. P."
      AuthorName.alias true, "Xu, Z.", "Xu, Z.-H."
      AuthorName.alias true, "Yensen, N.", "Yensen, N. P."
      AuthorName.alias true, "Zheng, Z.", "Zheng, Z.-M."
      AuthorName.alias true, "Zhou, S.", "Zhou, S.-Y."
      AuthorName.correct 'Colllingwood, C. A.', 'Collingwood, C. A.'
      AuthorName.correct 'Johnsos, R. A.', 'Johnson, R. A.'
      AuthorName.correct "Zimmermannn, F. K.", "Zimmermann, F. K."

      AuthorName.correct "Azarae, I.", "Azarae, I. Hj."
      AuthorName.alias true, "Azarae, H. I.", "Azarae, I. Hj."

      AuthorName.correct "Bestelmayer, B. T.", "Bestelmeyer, B. T."
      AuthorName.correct "Boosmsma, J. J.", "Boomsma, J. J."
      AuthorName.correct "Carrilloa, J. A.", "Carrillo, J. A."
      AuthorName.alias true, "Crewe, R.", "Crewe, R. M.", "Crewe, R. W."
      AuthorName.alias true, "Crosland, M. W. J.", "Crosland, M. W. L."
      AuthorName.correct "Mashchwitz, U.", "Maschwitz, U."
      AuthorName.correct "Masumoto, T.", "Matsumoto, T."
      AuthorName.alias true, "Matsumoto, T.", "Matumoto, T."
      AuthorName.correct "Nielson, M. G.", "Nielsen, M. G."
      AuthorName.correct "Torgerson, R. S.", "Torgerson, R. L."
      AuthorName.correct "Vinson, B.", "Vinson, S. B."
      AuthorName.correct "Woyciechowksi, M.", "Woyciechowski, M."
      AuthorName.correct "Sharaf, M. F.", "Sharaf, M. R."
      AuthorName.correct "Sharaf, R. M.", "Sharaf, M. R."
      AuthorName.alias true, "Sharaf, M. R.", "Sharaf, M."
      AuthorName.correct "Bacci, M., Jr", "Bacci, M., Jr."
      AuthorName.correct "Jahyny B", "Jahyny, B."
      AuthorName.correct "Kim, J-H.", "Kim, J.-H."
      AuthorName.correct "Martins, J., Jr", "Martins, J., Jr."
      AuthorName.correct "Radchenko, A", "Radchenko, A."
      AuthorName.correct "Chen, C.", "Chen, Z."
      AuthorName.correct "Bueno O", "Bueno, O. C."
      AuthorName.correct "Nomura", "Nomura, K."
      AuthorName.correct "Sanetra, M", "Sanetra, M."
      AuthorName.correct "Solis, D. R", "Solis, D. R."
      AuthorName.alias true, "Taylor, R.", "Taylor, R. W."

      # from the book
      AuthorName.alias true, "Acosta Salmerón, F. J.", "Acosta, F. J."
      AuthorName.alias true, "Arakelian, G. R.", "Arakelyan, G. R."
      AuthorName.alias true, "Arnol'di, K. V.", "Arnoldi, K. V."
      AuthorName.alias true, "Atanassov, N.", "Atanasov, N.", "Atanassow, N."
      AuthorName.alias true, "Billen, J. P. J.", "Billen, J."
      AuthorName.alias true, "Boven, J. K. A. van", "Boven, J. van"
      AuthorName.alias true, "Brandão, C. R. F.", "Ferreira Brandão, C. R."
      AuthorName.alias true, "Collingwood, C. A.", "Collingwood, C."
      AuthorName.alias true, "Comín, P.", "Comín del Río, P."
      AuthorName.alias true, "Dalla Torre, K. W. von", "Dalla Torre, C. G. de"
      AuthorName.alias true, "De Haro, A.", "De Haro Vera, A."
      AuthorName.alias true, "Deyrup, M.", "Deyrup, M. A."
      AuthorName.alias true, "Dlussky, G. M.", "Dlusskiy, G. M."
      AuthorName.alias true, "Donisthrope, H.", "Donisthorpe, H. S. J. K."
      AuthorName.alias true, "Escalante Gutiérrez, J. A.", "Escalante G., J. A."
      AuthorName.alias true, "Espadaler, X.", "Espadaler Gelabert, X."
      AuthorName.alias true, "Ezhikov, T.", "Ezikov, J."
      AuthorName.alias true, "Fontenla Rizo, J. L.", "Fontenla, J. L."
      AuthorName.alias true, "Frauenfeld, G. R. von", "Frauenfeld, G."
      AuthorName.alias true, "Gerstäcker, A.", "Gerstaecker, A."
      AuthorName.alias true, "Hermann, H. R.", "Hermann, H. R. Jr."
      AuthorName.alias true, "Ipinza-Regla, J. H.", "Ipinza, J.", "Ipinza-Regla, J."
      AuthorName.alias true, "Karavaiev, V.", "Karavajev, V.", "Karawaiew, W.", "Karawajew, W."
      AuthorName.alias true, "Krausse, A. H.", "Krausse, A."
      AuthorName.alias true, "Kusnezov, N.", "Kusnezow, N.", "Kuznetsov-Ugamsky, N. N.", "Kusnezov, N. N.",
                             "Kusnezov-Ugamsky, N.", "Kusnezow, N. N.", "Kusnezow-Ugamsky, N.",
                             "Kuznecov-Ugamskij, N. N.", "Kuznetzov-Ugamskij, N. N."
      AuthorName.alias true, "Lattke, J. E.", "Lattke, J."
      AuthorName.alias true, "Mackay, W. P.", "MacKay, W."
      AuthorName.alias true, "Mayr, G.", "Mayr, G. L."
      AuthorName.alias true, "Menozzi, C.", "Minozzi, C."
      AuthorName.alias true, "Motschoulsky, V. de", "Motschulsky, V. de"
      AuthorName.alias true, "Mukerjee, D.", "Mukerji, D.", "Mukherji, D."
      AuthorName.alias true, "Ortiz, F. J.", "Ortiz y Sánchez, F. J."
      AuthorName.alias true, "Quiran, E. M.", "Quiran, E."
      AuthorName.alias true, "Radchenko, A. G.", "Radtchenko, A. G.", "Radtschenko, A. G."
      AuthorName.alias true, "Ramos-Elorduy de Conconi, J.", "Conconi, J. R. E. de"
      AuthorName.alias true, "Reyes, J. L.", "Reyes Lopez, J. L."
      AuthorName.alias true, "Rodríguez, A.", "Rodríguez González, A."
      AuthorName.alias true, "Ruzsky, M.", "Ruzsky, M. D."
      AuthorName.alias true, "Schembri, S. P.", "Schembri, S."
      AuthorName.alias true, "Schkaff, B.", "Škaff, B."
      AuthorName.alias true, "Schmidt, G. H.", "Schmidt, G."
      AuthorName.alias true, "Tinaut, A.", "Tinaut, J. A.", "Tinaut Ranera, J. A."
      AuthorName.alias true, "Tiwari, R. N.", "Tewary, R. N."
      AuthorName.alias true, "Tohmé, G.", "Tohme, G."
      AuthorName.alias true, "Tohmé, H.", "Tohme, H."
      AuthorName.alias true, "Wesselinoff, G. D.", "Vesselinov, G."
      AuthorName.alias true, "Weyrauch, W.", "Weyrauch, W. K."
      AuthorName.alias true, "Guillou, E. J. F. le", "Le Guillou, E. J. F."

      # back out edits by Marek
      
      AuthorName.alias true, "Morley, B. D. W.", "Morley, D. B. W.", "Mosley, B. D. W."
      wragge = AuthorName.find_by_name "Morley, D. B. W."
      reference = Reference.find_by_cite_code '3219'
      ReferenceAuthorName.update_all({:author_name_id => wragge.id}, {:reference_id => reference.id, :position => 2})
      reference.update_author_names_string

      AuthorName.alias true, "Morley, B. D. W.", "Morley, D. W."
      wragge = AuthorName.find_by_name "Morley, D. W."
      reference = Reference.find_by_cite_code '1019'
      ReferenceAuthorName.update_all({:author_name_id => wragge.id}, {:reference_id => reference.id})
      reference.update_author_names_string

      AuthorName.alias true, "Ritter, H.", "Rittler, H."
      rittler = AuthorName.find_by_name "Rittler, H."
      reference = Reference.find_by_cite_code '8323'
      ReferenceAuthorName.update_all({:author_name_id => rittler.id}, {:reference_id => reference.id})
      reference.update_author_names_string
    end
  end

  def self.down
  end
end
