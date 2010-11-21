select name, count(*)
  from author_names 
  join reference_author_names on author_names.id = reference_author_names.author_name_id and position = 1
  join `references` on `references`.id = reference_author_names.reference_id
  where name in (
'Abdalla, F. C.',
'Abdul-Rassoul, M. S.',
'Abensperg-Traun, M.',
'Abouheif, E.',
'Acosta Salmerón, F. J.',
'Adam, A.',
'Addison, P.',
'Adeli, E.',
'Adolph, G. E.',
'Agbogba, C.',
'Ahmad, M. M. G.',
'Akre, R. D.',
'Albrecht, A.',
'Albrecht, M.',
'Aldana de la Torre, R. C.',
'Aldana, R. C.',
'Ali, M. F.',
'Allies, A. B.',
'Allred, D. M.',
'Almeida Filho, A. J. de',
'Almeida Toledo, L. F. de',
'Amstutz, M. E.',
'Andersson, B.',
'Andoni, V.',
'Andrewes, H. E.',
'Angus, C. J.',
'Antsiferov, V. M.',
'Apostolov, L. G.',
'Araujo, M. S.',
'Arias P., T. M.',
'Armbrecht, I.',
'Arnaud, P. H., Jr.',
'Aron, S.',
'Arthofer, W.',
'Astruc, C.',
'Athias-Henriot, C.',
'Attewell, P.',
'Attygalle, A. B.',
'Auel, H.',
'Ayala, F. J.',
'Ayre, G. L.',
'Baba, K.',
'Baba, Y.',
'Baden, R.',
'Baggini, A.',
'Bagnères, A.-G.',
'Bahntje, E.',
'Baiocco, L. M.',
'Baldridge, R. S.',
'Barquín, J.',
'Bart, K. M.',
'Barth, R.',
'Bartz, S. H.',
'Basibuyuk, H. H.',
'Bass, J. A.',
'Basu, P.',
'Basulati, K. K.',
'Baugnée, J. Y.',
'Baugnée, J.-Y.',
'Baur, A.',
'Bausenwein, F.',
'Beardsley, J. W.',
'Beattie, A. J.',
'Beck, D. E.',
'Beck, H.',
'Bedziak, I.',
'Behr, D.',
'Beibl, J.',
'Belin-Depoux, M.',
'Bellas, T.',
'Beláková, A.',
'Benois, A.',
'Bentley, B. L.',
'Bergström, G.',
'Berkelhamer, R. C.',
'Berland, L.',
'Berman, D. I.',
'Berndt, K.-P.',
'Beshers, S. N.',
'Bestelmayer, B. T.',
'Bestmann, H. J.',
'Bezdecka, P.',
'Bhatkar, A. P.',
'Bickford, E. E.',
'Bier, K.',
'Bigot, Y.',
'Birket-Smith, S. J. R.',
'Bitsch, J.',
'Blackwelder, R. E.',
'Blades, D. A.',
'Blard, F.',
'Blatrix, R.',
'Blinov, V. V.',
'Blüthgen, P.',
'Bode, E.',
'Bogoescu, C.',
'Boieiro, M.',
'Boieiro, M. R. C.',
'Bonaric, J.-C.',
'Bonavita-Cougourdan, A.',
'Bond, W.',
'Bonetto, A. A.',
'Borcard, Y.',
'Borchert, H. F.',
'Borges, D. S.',
'Bot, A. N. M.',
'Botes, A.',
'Boulton, A. M.',
'Bourke, A. F. G.',
'Bowley, D. R.',
'Bown, T. M.',
'Brand, J. M.',
'Brangham, A. N.',
'Breed, M. D.',
'Breen, J.',
'Bregant, E.',
'Brener, A. G. F.',
'Briese, D. T.',
'Brill, J. H.',
'Brimley, C. S.',
'Brophy, J. J.',
'Bruder, K. W.',
'Brun, L. O.',
'Bruneau de Miré, P.',
'Brunnert, A.',
'Brühl, C.',
'Brühl, C. A.',
'Bucher, E. H.',
'Buhs, J. B.',
'Burgman, M. A.',
'Burton, J. L.',
'Bution, M. L.',
'Bytinski-Salz, H.',
'Børgesen, L. W.',
'Bünzli, G. H.',
'Caesar, C. J.',
'Caldas, A.',
'Callcott, A.-M. A.',
'Calvert, P. P.',
'Camargo-Mathias, M. I.',
'Camilo, G. R.',
'Camlitepe, Y.',
'Cammaerts, M.-C.',
'Cammaerts, R.',
'Cammell, M. E.',
'Campiolo, S.',
'Carbonell Mas, C. S.',
'Carlton, C. E.',
'Carney, W. P.',
'Carpintero Ortega, S.',
'Carroll, C. R.',
'Carroll, J. F.',
'Carvalho, A. O. R. de',
'Carvalho, K. S.',
'Carvalho, M. B. de',
'Casolari, C.',
'Castaño-Meneses, G.',
'Catangui, M. A.',
'Cavill, G. W. K.',
'Cerdá, X.',
'Chahine-Hanna, N. H.',
'Chapela, I. H.',
'Chapuisat, M.',
'Chenuil, A.',
'Cherrett, J. M.',
'Chew, R. M.',
'Chhotani, D.',
'Chhotani, O. B.',
'Chilson, L. M.',
'Choe, J. C.',
'Chujo, M.',
'Claver, S.',
'Clay, R. E.',
'Cohic, F.',
'Colina, G. O.',
'Colombel, P.',
'Conklin, A.',
'Corn, M. L.',
'Coronado Padilla, R.',
'Corrêa, M. M.',
'Coulon, L.',
'Coyle, F. A.',
'Craig, R.',
'Cremer, S.',
'Crowson, R. A.',
'Cruz Landim, C. da',
'Csosz, S.',
'Culver, D. C.',
'Cupul-Magañ, F. G.',
'Cîrdei, F.',
'Daguerre, J. B.',
'Dahbi, A.',
'Dalecky, A.',
'Dallas, W. S.',
'Daloze, D.',
'Dauber, J.',
'Dazzini Valcurone, M.',
'De Carli, P.',
'De Kock, A. E.',
'De Menten, L.',
'Debaisieux, P.',
'Deblauwe, I.',
'Debouge, M.H.',
'Degnan, P. H.',
'Deichmüller, J. V.',
'Dekoninck, W.',
'Delage, B.',
'Delfino, M. A.',
'Detrain, C.',
'Devi, C. M.',
'Dewes, E.',
'Dewitz, H.',
'Dey, D.',
'Diehl, E.',
'Diehl-Fleig, E.',
'Diehl-Flieg, E.',
'Dietemann, V.',
'Diffie, S.',
'Diniz-Filho, J. A. F.',
'Dmitrienko, V. K.',
'Dobrzanski, J.',
'Donnelly, D.',
'Doums, C.',
'Dubey, A.K.',
'Dubovikoff, D. A.',
'Duffield, R. M.',
'Dunn, R. R.',
'Dunton, R. F.',
'Díaz Azpiazu, M.',
'Düssmann, O.',
'Eastlake Chew, A.',
'Eastwood, R.',
'Echols, H. W.',
'Eckert, J. E.',
'Eder, J.',
'Eichler, W.',
'Eilmus, S.',
'Ellison, A. M.',
'Elton, E. T. G.',
'Englisch, T.',
'Esben-Petersen, P.',
'Escalante Gutiérrez, J. A.',
'Espelie, K. E.',
'Estrada M. C.',
'Evershed, R. P.',
'Fabres, G.',
'Fadini, M. A. M.',
'Fales, H. M.',
'Faulds, W.',
'Febvay, G.',
'Feldhaar, H.',
'Felisberti, F.',
'Felke, M.',
'Feller, C.',
'Fellers, J. H.',
'Felton, J. C.',
'Fenger, H.',
'Fenyósiné, H. A.',
'Fernández-Marín, H.',
'Ferrer, J.',
'Ferster, B.',
'Fiala, J.',
'Fiebrig, K.',
'Fielde, A. M.',
'Finnegan, R. J.',
'Flanders, S. E.',
'Fletcher, D. J. C.',
'Floater, G. J.',
'Floren, A.',
'Flores-Maldonado, K. Y.',
'Foitzik, S.',
'Fonseca, C. R. F.',
'Ford, F. C.',
'Forskål, P.',
'Forsyth, A.',
'Foucaud, J.',
'Fournier, D.',
'Fraga, N. J.',
'Franch, J.',
'Frank, S. R.',
'Franks, N. R.',
'François, J.',
'Freitag, A.',
'Freitas, A. V. L.',
'Fritzsche, R.',
'Frumhoff, P. C.',
'Fröhlich, C.',
'Fröhlich, K. O.',
'Fuentes, J. E.',
'Fuentes, M. B.',
'Fukai, T.',
'Funakubo, H.',
'Gadagkar, R.',
'Gahl, H.',
'Gallé, L.',
'Gama, V.',
'Ganglbauer, L.',
'García, M.',
'García-Pérez, J. A.',
'Gardner, W.',
'Garling, L.',
'Garraffo, H. M.',
'Gartner, I.',
'Gateva, R.',
'Gavrilov, K.',
'Gehring, W. J.',
'Gerlach, J.',
'Gerstäcker, A.',
'Gertsch, P.',
'Gertsch, P. J.',
'Gestro, R.',
'Ghigi, A.',
'Ghilarov, M. S.',
'Gillespie, D. S.',
'Giovannotti, M.',
'Gjelsvik, N.',
'Gladstone, D. E.',
'Glancey, B. M.',
'Gleim, K.-H.',
'Glover, P. E.',
'Glöckner, W. E.',
'Goaga, A.',
'Gobin, B.',
'Godden, C.',
'Goeldi, E.',
'Goll, W.',
'Gonzalez Villareal, D.',
'González Pérez, J. L.',
'Goodisman, M. A. D.',
'Gorman, J. S. T.',
'Goropashnaya, A. V.',
'Gotelli, N. J.',
'Gotzek, D.',
'Gove, A. D.',
'Goñi, B.',
'Grasso, D. A.',
'Greenberg, L.',
'Griep, E.',
'Groc, S.',
'Gronenberg, W.',
'Grutzmacher, D. D.',
'Guilbert, E.',
'Guittini, U.',
'Gunawardene, N. R.',
'Gundlach, J.',
'Gunsalam, G.',
'Gurgel-Gonçalves, R.',
'Gusmão, L. G.',
'Gómez Aval, K.',
'Haak, U.',
'Hacobian, B. S.',
'Haddow, A. J.',
'Haeseler, V.',
'Hagan, H. R.',
'Hallett, H. M.',
'Halliday, R. B.',
'Halverson, D. D.',
'Hamaguchi, K.',
'Hannan, M. A.',
'Hansen, L. D.',
'Hansen, S. R.',
'Harvey, P. R.',
'Hauck, V.',
'Hayashi, N.',
'Hazeltine, W. F.',
'Heatwole, H.',
'Hefetz, A.',
'Heil, M.',
'Helms Cahan, S.',
'Hemming, F.',
'Hennig, W.',
'Henshaw, M. T.',
'Herbers, J. M.',
'Hertlein, L. G.',
'Hespenheide, H. A.',
'Hess, C. G.',
'Heuer, H. G.',
'Hilburn, D. J.',
'Hincapié, C.',
'Hinkle, G.',
'Hinton, H. E.',
'Hirano, I.',
'Hirosawa, H.',
'Hites, N. L.',
'Hoare, R. J. B.',
'Hocking, B.',
'Hodgkiss, I. J.',
'Hoffman, D. R.',
'Hohorst, B.',
'Hollingsworth, M. J.',
'Holt, J. A.',
'Holway, D.',
'Holway, D. A.',
'Hopkinson, J.',
'Hosking, A. C.',
'Hsu, S.-L.',
'Huddleston, E. W.',
'Hughes, J.',
'Hughes, W. O. H.',
'Hôzawa, S.',
'Höfener, C.',
'Högmo, O.',
'Imanishi, K.',
'International Commission on Zoological Nomenclature',
'Ipinza-Regla, J. H.',
'Ipser, R. M.',
'Iredale, T.',
'Itino, T.',
'Jaeger, E.',
'Jaennicke, F.',
'Jagodzinska, Z.',
'Jahyny, B.',
'Jaitrong, W.',
'Jakubisiak, S.',
'Janssen, E.',
'Jeanne, R. L.',
'Jeffery, H. G.',
'Jekel, H.',
'Jiménez Rojas, J.',
'Jolivet, P.',
'Jonkman, J. C. M.',
'Jordan, K. H. C.',
'Jourdan, H.',
'Jucci, C.',
'Julian, G. E.',
'Jusino-Atresino, R.',
'Járdán, C.',
'Jäch, M. A.',
'Jørum, P.',
'Kaczmarek, W.',
'Kaplin, V. G.',
'Kappel, A. W.',
'Karpinski, J. J.',
'Kaschef, A. H.',
'Kasugai, M.',
'Kautz, S.',
'Kawahara, Y.',
'Keall, J. B.',
'Keister, M.',
'Kermarrec, A.',
'Kern, F.',
'Kevan, D. K. McE',
'Kholová, H.',
'Khomenko, V. N.',
'Khoo, Y. H.',
'Kidd, L. N.',
'Kidd, M. G.',
'Kihara, A.',
'Kikuchi, T.',
'Klimetzek, D.',
'Kloft, W. J.',
'Klotz, J. H.',
'Knaden, M.',
'Knauer, F.',
'Knechtel, W. K.',
'Knudtson, B. K.',
'Koen, J. H.',
'Kofler, A.',
'Kogure, T.',
'Kohn, M.',
'Kostjuk, J. A.',
'Kotzias, H.',
'Kratochvíl, J.',
'Kremer, G.',
'Krieger, M. J. B.',
'Krishna Ayyar, P. N.',
'Kroyer, H. N.',
'Kula, E.',
'Kumar, R.',
'Kume, S.',
'Kupianskaya, A. N.',
'Kvamme, T.',
'Kôno, H.',
'Kümmerli, R.',
'Kürschner, I.',
'La Rivers, I.',
'LaMon, B.',
'Labuda, M.',
'Lachaud, J. P.',
'Laeger, T.',
'Laine, K. J.',
'Lanne, B. S.',
'Larsson, S. G.',
'Lauterer, P.',
'Law, J. H.',
'Leclerc, J.',
'Leclercq, S.',
'Ledoux, A.',
'Leech, H. B.',
'Lefeber, B. A.',
'Legakis, A.',
'Leprince, D. J.',
'Lessard, J.-P.',
'Leuthold, R. H.',
'Levings, S. C.',
'Levins, R.',
'Lewis, S. E,',
'Liebig, J.',
'Lindström, K.',
'Lino-Neto, J.',
'Lipski, N.',
'Lloyd, H. A.',
'Lobry de Bruyn, L. A.',
'Lofgren, C. S.',
'Lokay, E.',
'Lokkers, C.',
'Lombarte, A.',
'Loos-Frank, B.',
'Lopes, B. C.',
'Lopes, H. S.',
'Lorite, P.',
'Loureiro, M. C.',
'Lubin, Y. D.',
'Lucchese, M. E. de P.',
'Lude, A.',
'Luque García, G.',
'Lutinski, J. A.',
'López Moreno, I. R.',
'López, F.',
'López-Moreno, I. R.',
'Maavara, V.',
'MacArthur, R. H.',
'MacConnell, J. G.',
'MacDonagh, E. J.',
'Macaranas, J. M.',
'Magalhães, L. E. de',
'Mallis, A.',
'Malozemova, L. A.',
'Malyshev, S. I.',
'Mamaev, B. M.',
'Mamet, R.',
'Manabe, K.',
'Marcus, H.',
'Mariconi, F. A. M.',
'Marinho C. G. S.',
'Martini, R.',
'Martínez-Ibáñez, M. D.',
'Mathias, M. I. C.',
'Mazur, S.',
'McGlynn, T. P.',
'McGurk, D. J.',
'McInnes, D. A.',
'Medeiros, M. A. de',
'Medel, R. G.',
'Mehlhop, P.',
'Meinwald, J.',
'Menzel, J. G.',
'Menzel, R.',
'Mescher, M. C.',
'Meyne, J.',
'Mikheyev, A. S.',
'Minkiewicz, R.',
'Mintzer, A. C.',
'Miradoli Zatti, M. A.',
'Missa, O.',
'Mitroshina, L. A.',
'Miyata, H.',
'Mizutani, A.',
'Monastero, S.',
'Monnin, T.',
'Moody, J. V.',
'Morais, H. C.',
'Moreira, D. D. O.',
'Mori, A.',
'Morillo, C.',
'Morini, M. S. de C.',
'Morton, S. R.',
'Moya, J.',
'Mulsant, E.',
'Munroe, P. D.',
'Munsee, J. R.',
'Musthak Ali, T. M.',
'Márquez Luna, J.',
'Möglich, M.',
'Mühlenberg, M.',
'Münch, W.',
'Na, J. P. S.',
'Nachtwey, R.',
'Nakamura, N.',
'Nakano, T.',
'Nascimento, I. C.',
'Nascimento, I. C. do',
'Nascimento, R. R. do',
'Nascimento, R. R. do, Schoeters, E.',
'Nefedov, N. I.',
'Negoro, H.',
'Negrobov, O. P.',
'Nelmes, E.',
'Netshilaphala, N. M.',
'Niculita, H.',
'Niemelä, J.',
'Niemeyer, H.',
'Nikitin, M. I.',
'Nilsson, O.',
'Nipperess, D. A.',
'Nolan, E. J. (ed.)',
'Nomura, K.',
'Nonacs, P.',
'Nowbahari, E.',
'Nowotny, H.',
'Noyce, K. V.',
'Nuhn, T. P.',
'Nunes, P. H.',
'O\'Donnell, S.',
'Oberstadt, B.',
'Obin, M. S.',
'Ochi, K.',
'Oeser, R.',
'Ohl, M.',
'Ohnishi, H.',
'Ohta, Y.',
'Okano, K.',
'Olson, D. M.',
'Omelchenko, L. V.',
'Orivel, J.',
'Orr, M. R.',
'Ortius, D.',
'Ortius-Lechner, D.',
'Oster, G. F.',
'Oswald, J. D.',
'Ouellette, G. D.',
'Ovazza, M.',
'O’Donnell, S.',
'Pace, R.',
'Padilla, R. C.',
'Paik, W. H.',
'Palenitschko, Z. G.',
'Palma, R. L.',
'Palomeque, T.',
'Paramonov, S. Y.',
'Pardo Vargas, R.',
'Pardo, X.',
'Parfitt, E.',
'Passerin d\'Entrèves, P.',
'Pasteels, J. M.',
'Paul, J.',
'Pavon, L. F.',
'Pearcy, M.',
'Pearson, B.',
'Penev, S.',
'Peregrine, D. J.',
'Perfecto, I.',
'Pesquero, M. A.',
'Petersen-Braun, M.',
'Petrulevicius, J. F.',
'Picquet, N.',
'Piek, T.',
'Pietrantonio, P. V.',
'Pignalberi, C. T.',
'Pogorevici, N.',
'Pollock, G. B.',
'Pontin, A. J.',
'Poole, R. W.',
'Popovici-Baznosanu, A.',
'Popp, M. P.',
'Potts, R. W. L.',
'Pressick, M. L.',
'Preuss, G.',
'Procter, W.',
'Pullen, B. E.',
'Punttila, P.',
'Pusvaskyte, O.',
'Péru, L.',
'Queiroz, M. V. B.',
'Quek, S. P.',
'Quek, S.-P.',
'Quiran, E. M.',
'Quiroz-Robledo, L.',
'Quiroz-Robledo, L. N.',
'Quispel, A.',
'Rabitsch, W.',
'Ragonot, E. L.',
'Ramdas Menon, M. G.',
'Rammoser, H.',
'Ramos Lacau, L. de S.',
'Ramos-Elorduy de Conconi, J.',
'Randuška, P.',
'Ranta, E.',
'Raqué, K.-F.',
'Rastogi, N.',
'Ratchford, J. S.',
'Ratsirarson, H.',
'Reder, E.',
'Reichel, H.',
'Reimer, N.',
'Reimer, N. J.',
'Reis, Y. T.',
'Retana, J.',
'Rettenmeyer, C. W.',
'Reyes López, J.',
'Reznikova, Z. I.',
'Rhoades, R. B.',
'Ribas, C. R.',
'Rice, H. M. A.',
'Riemann, H.',
'Ritter, H.',
'Rittler, H.',
'Robson, S. K. A.',
'Roche, R. K.',
'Rockwood, L. L.',
'Rodriguez-Garza, J. A.',
'Rodríguez Garza, J. A.',
'Rodríguez, A.',
'Rohlfien, K.',
'Rojas Fernández, P.',
'Rojas, P.',
'Rojas-Fernández, P.',
'Roma, G. C.',
'Romand, B. E. de',
'Ronquist, F.',
'Room, P. M.',
'Roonwal, M. L.',
'Roques, L.',
'Rossbach, M. H.',
'Rossi de Garcia, E.',
'Rotramel, G. L.',
'Russell, J. A.',
'Russell, W. E.',
'Räsänen, V.',
'Réaumur, R. A. F. de',
'Ríos-Casanova, L.',
'Rögener, J.',
'Rüger, M. H.',
'Rüppell, O.',
'Saaristo, M. I.',
'Safford, W. E.',
'Salinas, P. J.',
'Salvarani, A.',
'Sameshima, S.',
'Samson, D. A.',
'Samways, M. J.',
'Sanderson, M. W.',
'Santos-Colares, M. C., Viégas, J., Martino Roth, M. G., Loeck, A. E.',
'Sartori, M.',
'Sauer, C.',
'Saux, C.',
'Scheffrahn, R. H.',
'Scheurer, S.',
'Schilder, K.',
'Schilliger, E.',
'Schimmer, F.',
'Schneider, J. S.',
'Schneider, L. C.',
'Schneirla, T. C.',
'Schoenherr, C. J.',
'Schoeters, E.',
'Schrempf, A.',
'Schug, A.',
'Schwander, T.',
'Schweigger, A. F.',
'Schön, A.',
'Schönitzer, K.',
'Scott, H.',
'Seevers, C. H.',
'Seima, F. A.',
'Sellenschlo, U.',
'Seppä, P.',
'Seyma, F. A.',
'Sharplin, J.',
'Shen, L.',
'Shindo, M.',
'Shoemaker, D. D.',
'Shyamalanath, S.',
'Singleton, J.',
'Sitthicharoenchai, D.',
'Skaife, S. H.',
'Skinner, G. J.',
'Skott, C.',
'Sledge, M. F.',
'Snodgrass, R. E.',
'Sobrinho, T. G.',
'Somfai, E.',
'Sommer, F.',
'Sommer, K.',
'Sonnenburg, H.',
'Soroker, V.',
'Sorvari, J.',
'Soto, S. U.',
'Souza Paula, H.',
'Spagna, J. C.',
'Spangler, H. G.',
'Sparks, S. D.',
'Spooner, G. M.',
'Sposito, E. C.',
'Stafleu, F. A.',
'Stainforth, T.',
'Stankiewicz, A. M.',
'Starr, C. K.',
'Stawarski, I.',
'Stein, M. B.',
'Steinwarz, D.',
'Stolpe, H.',
'Stradling, D. J.',
'Street, M. D.',
'Strickland, A. H.',
'Stuart, R. J.',
'Stummer, A.',
'Sturm, J.',
'Suarez, A. V.',
'Suchocka, H.',
'Sudd, J. H.',
'Suehiro, A.',
'Sugerman, B. B.',
'Sugiyama, T.',
'Sullender, B. W.',
'Sumner, S.',
'Sundström, L.',
'Sunil Kumar, M.',
'Suzzoni, J. P.',
'Suñer i Escriche, D.',
'Suñer, D.',
'Swainson W.',
'Sweeney, R. C. H.',
'Sáiz, F.',
'Sörensen, U.',
'Tak, N.',
'Takechi, F.',
'Taschenberg, E. L.',
'Tegelström, H.',
'Theobald-Ley, S.',
'Theunert, R.',
'Thorne, B. L.',
'Théobald, N.',
'Timmins, C. J.',
'Tobin, J. E.',
'Tokunaga, M.',
'Tonapi, G. T.',
'Topoff, H.',
'Torgerson, R. L.',
'Torre-Grossa, J. P.',
'Torres-Contreras, H.',
'Touyama, Y.',
'Trivers, R. L.',
'Trojan, P.',
'Trontti, K.',
'Troppmair, H.',
'Tschinkel, W. R.',
'Tshiguvho, T. E.',
'Tsutsui, N. D.',
'Tsyubik, M. M.',
'Tuff, D. W.',
'Tynes, J. S.',
'Ugawa, Y.',
'Umphrey, G. J.',
'Urich, F. W.',
'Van Pelt, A. F.',
'Van der Have, T. M.',
'Vanderwoude, C.',
'Vanni, S.',
'Vargo, E. L.',
'Vasilev, I.',
'Vecht, J. van der',
'Vepsäläinen K.',
'Vepsäläinen, K.',
'Verdinelli, M.',
'Vergara Navarro, E. V.',
'Vernalha, M. M.',
'Vernier, R.',
'Veuille, M.',
'Vick, K. W.',
'Viginier, B.',
'Vilela, E. F.',
'Villesen, P.',
'Visicchio, R.',
'Viswanath, B. N.',
'Vogelsanger, E.',
'Vogrin, V.',
'Volny, V. P.',
'Von Sicard, N. A. E.',
'Vowles, D. M.',
'Vysoky, V.',
'Vásquez Bolaños, M.',
'Wagner-Ziemka, A.',
'Waldkircher, G.',
'Wardlaw, J. C.',
'Ware, A. B.',
'Warren, L. O.',
'Watanasit, S.',
'Waterhouse, F. H.',
'Watson, E. M.',
'Watt, A. D.',
'Watts, C. H. S.',
'Way, M. J.',
'Weir, J. S.',
'Weiser, M. D.',
'Welch, R. C.',
'Wengris, J.',
'Wengrisówna, J.',
'Wenner, A. M.',
'Wenseleers, T.',
'Werner, P.',
'Werringloer, A.',
'Westhoff, V.',
'Weyrauch, W.',
'Whitehead, P. F.',
'Whitford, W. G.',
'Whiting, J. H., Jr.',
'Whiting, P. W.',
'Whitley, G.',
'Widodo, E. S.',
'Wiel, P. van der',
'Wiernasz, D. C.',
'Wiezik, M.',
'Wilkinson, R. C.',
'Wisdom, W. A.',
'Woinarski, J. C. Z.',
'Wollmann, K.',
'Woodall, P. F.',
'Wray, D. L.',
'Wroughton, R. C.',
'Würmli, M.',
'Yamamoto, M.-T.',
'Yamamoto, T.',
'Yasuno, M.',
'York, A.',
'Zakharov, A. A.',
'Zara, F. J.',
'Zayas, L.',
'Zdobnitzky, W.',
'Zhizhilashvili, T. I.',
'Zhou S. Y.',
'Zientz, E.',
'Zimmerman, E. C.',
'Zittser, T. V.',
'Zorilla, J. M.',
'Zylberberg, L.',
'Zálesky, M.',
'Zíkan, W.',
'van Hamburg, H.',
'van der Hammen, T.',
'von Aesch, L.',
'Österreichischen Gesellschaft für Ameisenkunde',
'Übler, E.'
)
  group by name
  order by count(*) desc

+-----------------------------------------------------+----------+
| name                                                | count(*) |
+-----------------------------------------------------+----------+
| Marcus, H.                                          |       19 |
| Kratochvíl, J.                                      |       14 |
| Zálesky, M.                                         |       14 |
| Schoeters, E.                                       |       13 |
| Gronenberg, W.                                      |       10 |
| Gallé, L.                                           |        9 |
| Ohta, Y.                                            |        9 |
| Franks, N. R.                                       |        8 |
| Schneirla, T. C.                                    |        8 |
| Acosta Salmerón, F. J.                              |        8 |
| Vysoky, V.                                          |        8 |
| Seppä, P.                                           |        8 |
| Lorite, P.                                          |        8 |
| Bourke, A. F. G.                                    |        7 |
| Dekoninck, W.                                       |        7 |
| Stuart, R. J.                                       |        7 |
| Cammaerts, M.-C.                                    |        7 |
| Touyama, Y.                                         |        7 |
| Cavill, G. W. K.                                    |        7 |
| Klimetzek, D.                                       |        7 |
| Okano, K.                                           |        6 |
| Van Pelt, A. F.                                     |        6 |
| Zhizhilashvili, T. I.                               |        6 |
| Malyshev, S. I.                                     |        6 |
| Berndt, K.-P.                                       |        6 |
| Preuss, G.                                          |        6 |
| Attewell, P.                                        |        6 |
| Csosz, S.                                           |        6 |
| Attygalle, A. B.                                    |        6 |
| Ali, M. F.                                          |        6 |
| Dmitrienko, V. K.                                   |        6 |
| Palomeque, T.                                       |        6 |
| Gerstäcker, A.                                      |        6 |
| López, F.                                           |        6 |
| Pontin, A. J.                                       |        6 |
| Möglich, M.                                         |        5 |
| Samways, M. J.                                      |        5 |
| Rettenmeyer, C. W.                                  |        5 |
| Théobald, N.                                        |        5 |
| Münch, W.                                           |        5 |
| Sellenschlo, U.                                     |        5 |
| Goñi, B.                                            |        5 |
| Brand, J. M.                                        |        5 |
| Pearson, B.                                         |        5 |
| Gama, V.                                            |        5 |
| Legakis, A.                                         |        5 |
| Herbers, J. M.                                      |        5 |
| Beattie, A. J.                                      |        5 |
| Bergström, G.                                       |        5 |
| Bregant, E.                                         |        5 |
| Cerdá, X.                                           |        5 |
| Floren, A.                                          |        4 |
| Quiran, E. M.                                       |        4 |
| Briese, D. T.                                       |        4 |
| Halliday, R. B.                                     |        4 |
| Duffield, R. M.                                     |        4 |
| Cremer, S.                                          |        4 |
| Andoni, V.                                          |        4 |
| Mathias, M. I. C.                                   |        4 |
| Sundström, L.                                       |        4 |
| Quiroz-Robledo, L. N.                               |        4 |
| Mazur, S.                                           |        4 |
| Kvamme, T.                                          |        4 |
| Gadagkar, R.                                        |        4 |
| Krieger, M. J. B.                                   |        4 |
| Vásquez Bolaños, M.                                 |        4 |
| Reznikova, Z. I.                                    |        4 |
| Escalante Gutiérrez, J. A.                          |        4 |
| Suarez, A. V.                                       |        4 |
| Jourdan, H.                                         |        4 |
| Punttila, P.                                        |        4 |
| International Commission on Zoological Nomenclature |        4 |
| Glancey, B. M.                                      |        4 |
| Ipinza-Regla, J. H.                                 |        4 |
| Gleim, K.-H.                                        |        4 |
| Almeida Filho, A. J. de                             |        4 |
| Keall, J. B.                                        |        4 |
| Evershed, R. P.                                     |        4 |
| Nowotny, H.                                         |        4 |
| Riemann, H.                                         |        4 |
| Goropashnaya, A. V.                                 |        4 |
| Shoemaker, D. D.                                    |        4 |
| Diehl-Fleig, E.                                     |        4 |
| Itino, T.                                           |        4 |
| Aron, S.                                            |        3 |
| Gobin, B.                                           |        3 |
| Heatwole, H.                                        |        3 |
| Spooner, G. M.                                      |        3 |
| Mizutani, A.                                        |        3 |
| Craig, R.                                           |        3 |
| Shyamalanath, S.                                    |        3 |
| Fales, H. M.                                        |        3 |
| Clay, R. E.                                         |        3 |
| Vanderwoude, C.                                     |        3 |
| Hefetz, A.                                          |        3 |
| Kürschner, I.                                       |        3 |
| Wenseleers, T.                                      |        3 |
| Bonaric, J.-C.                                      |        3 |
| Dauber, J.                                          |        3 |
| Sonnenburg, H.                                      |        3 |
| Hoffman, D. R.                                      |        3 |
| Goeldi, E.                                          |        3 |
| Rüppell, O.                                         |        3 |
| Blackwelder, R. E.                                  |        3 |
| Jolivet, P.                                         |        3 |
| Helms Cahan, S.                                     |        3 |
| Bahntje, E.                                         |        3 |
| Brophy, J. J.                                       |        3 |
| Vick, K. W.                                         |        3 |
| Hannan, M. A.                                       |        3 |
| Knechtel, W. K.                                     |        3 |
| Beláková, A.                                        |        3 |
| Greenberg, L.                                       |        3 |
| Aldana, R. C.                                       |        3 |
| Cammaerts, R.                                       |        3 |
| Hughes, W. O. H.                                    |        3 |
| Baugnée, J.-Y.                                      |        3 |
| Gjelsvik, N.                                        |        3 |
| Saaristo, M. I.                                     |        3 |
| Skott, C.                                           |        3 |
| Baur, A.                                            |        3 |
| Munsee, J. R.                                       |        3 |
| Umphrey, G. J.                                      |        3 |
| Zakharov, A. A.                                     |        3 |
| Dewes, E.                                           |        3 |
| Schönitzer, K.                                      |        3 |
| Finnegan, R. J.                                     |        3 |
| Kofler, A.                                          |        3 |
| Tobin, J. E.                                        |        3 |
| Allred, D. M.                                       |        3 |
| Nonacs, P.                                          |        3 |
| Janssen, E.                                         |        3 |
| Fellers, J. H.                                      |        3 |
| Vepsäläinen, K.                                     |        3 |
| Welch, R. C.                                        |        3 |
| Felton, J. C.                                       |        3 |
| Haeseler, V.                                        |        3 |
| Perfecto, I.                                        |        3 |
| Nachtwey, R.                                        |        3 |
| MacDonagh, E. J.                                    |        3 |
| Hayashi, N.                                         |        3 |
| Tak, N.                                             |        3 |
| Hagan, H. R.                                        |        3 |
| Cîrdei, F.                                          |        3 |
| Topoff, H.                                          |        3 |
| Morton, S. R.                                       |        3 |
| Tsutsui, N. D.                                      |        2 |
| Sommer, F.                                          |        2 |
| Rojas Fernández, P.                                 |        2 |
| Dubovikoff, D. A.                                   |        2 |
| Gotelli, N. J.                                      |        2 |
| Wroughton, R. C.                                    |        2 |
| Akre, R. D.                                         |        2 |
| Camargo-Mathias, M. I.                              |        2 |
| Levings, S. C.                                      |        2 |
| Birket-Smith, S. J. R.                              |        2 |
| Diehl-Flieg, E.                                     |        2 |
| Carroll, C. R.                                      |        2 |
| Lucchese, M. E. de P.                               |        2 |
| Sommer, K.                                          |        2 |
| Olson, D. M.                                        |        2 |
| Klotz, J. H.                                        |        2 |
| Fukai, T.                                           |        2 |
| Menzel, R.                                          |        2 |
| Chapuisat, M.                                       |        2 |
| Malozemova, L. A.                                   |        2 |
| Vernier, R.                                         |        2 |
| Basu, P.                                            |        2 |
| Pasteels, J. M.                                     |        2 |
| Carroll, J. F.                                      |        2 |
| Mühlenberg, M.                                      |        2 |
| Astruc, C.                                          |        2 |
| Wiel, P. van der                                    |        2 |
| Gove, A. D.                                         |        2 |
| Foitzik, S.                                         |        2 |
| Retana, J.                                          |        2 |
| Bagnères, A.-G.                                     |        2 |
| Stafleu, F. A.                                      |        2 |
| Huddleston, E. W.                                   |        2 |
| Loos-Frank, B.                                      |        2 |
| O'Donnell, S.                                       |        2 |
| Brimley, C. S.                                      |        2 |
| Werner, P.                                          |        2 |
| Nascimento, R. R. do                                |        2 |
| Ferster, B.                                         |        2 |
| Luque García, G.                                    |        2 |
| Dazzini Valcurone, M.                               |        2 |
| Beibl, J.                                           |        2 |
| Cherrett, J. M.                                     |        2 |
| Paik, W. H.                                         |        2 |
| Hughes, J.                                          |        2 |
| Feldhaar, H.                                        |        2 |
| Quispel, A.                                         |        2 |
| Cruz Landim, C. da                                  |        2 |
| Mikheyev, A. S.                                     |        2 |
| Ledoux, A.                                          |        2 |
| Chew, R. M.                                         |        2 |
| Wiezik, M.                                          |        2 |
| Lindström, K.                                       |        2 |
| Ford, F. C.                                         |        2 |
| Vasilev, I.                                         |        2 |
| Moody, J. V.                                        |        2 |
| Zimmerman, E. C.                                    |        2 |
| Skinner, G. J.                                      |        2 |
| Diniz-Filho, J. A. F.                               |        2 |
| Pearcy, M.                                          |        2 |
| Carvalho, M. B. de                                  |        2 |
| Adam, A.                                            |        2 |
| Ugawa, Y.                                           |        2 |
| Maavara, V.                                         |        2 |
| Hansen, L. D.                                       |        2 |
| De Kock, A. E.                                      |        2 |
| Hollingsworth, M. J.                                |        2 |
| Pullen, B. E.                                       |        2 |
| Lino-Neto, J.                                       |        2 |
| Manabe, K.                                          |        2 |
| Bestmann, H. J.                                     |        2 |
| Felke, M.                                           |        2 |
| Culver, D. C.                                       |        2 |
| Rodríguez Garza, J. A.                              |        2 |
| Weyrauch, W.                                        |        2 |
| Negoro, H.                                          |        2 |
| Bytinski-Salz, H.                                   |        2 |
| Wagner-Ziemka, A.                                   |        2 |
| Room, P. M.                                         |        2 |
| Mintzer, A. C.                                      |        2 |
| Suzzoni, J. P.                                      |        2 |
| Lipski, N.                                          |        2 |
| Brangham, A. N.                                     |        2 |
| Vecht, J. van der                                   |        2 |
| Bezdecka, P.                                        |        2 |
| Blinov, V. V.                                       |        2 |
| Villesen, P.                                        |        2 |
| Medeiros, M. A. de                                  |        2 |
| Castaño-Meneses, G.                                 |        2 |
| Whitehead, P. F.                                    |        2 |
| Chilson, L. M.                                      |        2 |
| Urich, F. W.                                        |        2 |
| Harvey, P. R.                                       |        2 |
| Lloyd, H. A.                                        |        2 |
| Mariconi, F. A. M.                                  |        2 |
| Mori, A.                                            |        2 |
| Snodgrass, R. E.                                    |        2 |
| Kihara, A.                                          |        2 |
| Fröhlich, K. O.                                     |        2 |
| Rodríguez, A.                                       |        2 |
| Medel, R. G.                                        |        2 |
| Donnelly, D.                                        |        2 |
| Beardsley, J. W.                                    |        2 |
| Sudd, J. H.                                         |        2 |
| Whitford, W. G.                                     |        2 |
| Choe, J. C.                                         |        2 |
| Borges, D. S.                                       |        2 |
| Roques, L.                                          |        2 |
| Holway, D. A.                                       |        2 |
| Sweeney, R. C. H.                                   |        2 |
| Goodisman, M. A. D.                                 |        2 |
| Fournier, D.                                        |        2 |
| Salinas, P. J.                                      |        2 |
| Morillo, C.                                         |        2 |
| Ipser, R. M.                                        |        2 |
| Bickford, E. E.                                     |        2 |
| Tschinkel, W. R.                                    |        2 |
| Dahbi, A.                                           |        2 |
| Armbrecht, I.                                       |        2 |
| Kikuchi, T.                                         |        2 |
| Bruneau de Miré, P.                                 |        2 |
| Agbogba, C.                                         |        2 |
| Reichel, H.                                         |        2 |
| Baba, K.                                            |        2 |
| Wengris, J.                                         |        2 |
| Morini, M. S. de C.                                 |        2 |
| Loureiro, M. C.                                     |        2 |
| Arnaud, P. H., Jr.                                  |        2 |
| Wray, D. L.                                         |        2 |
| Niculita, H.                                        |        2 |
| Jusino-Atresino, R.                                 |        2 |
| Eichler, W.                                         |        2 |
| Berkelhamer, R. C.                                  |        2 |
| Leuthold, R. H.                                     |        2 |
| Quek, S.-P.                                         |        2 |
| Kermarrec, A.                                       |        2 |
| Basibuyuk, H. H.                                    |        2 |
| Stradling, D. J.                                    |        2 |
| Wengrisówna, J.                                     |        2 |
| Sameshima, S.                                       |        2 |
| Nakano, T.                                          |        1 |
| Jeffery, H. G.                                      |        1 |
| Fenyósiné, H. A.                                    |        1 |
| Boieiro, M.                                         |        1 |
| Randuska, P.                                        |        1 |
| Lubin, Y. D.                                        |        1 |
| Hallett, H. M.                                      |        1 |
| Dallas, W. S.                                       |        1 |
| Kloft, W. J.                                        |        1 |
| Fuentes, M. B.                                      |        1 |
| Bucher, E. H.                                       |        1 |
| Vogrin, V.                                          |        1 |
| Menzel, J. G.                                       |        1 |
| Hodgkiss, I. J.                                     |        1 |
| Beck, H.                                            |        1 |
| Sugiyama, T.                                        |        1 |
| Pesquero, M. A.                                     |        1 |
| Sullender, B. W.                                    |        1 |
| Larsson, S. G.                                      |        1 |
| Petersen-Braun, M.                                  |        1 |
| Lauterer, P.                                        |        1 |
| Goaga, A.                                           |        1 |
| Chahine-Hanna, N. H.                                |        1 |
| Chapela, I. H.                                      |        1 |
| Whitley, G.                                         |        1 |
| Abdalla, F. C.                                      |        1 |
| Schimmer, F.                                        |        1 |
| Claver, S.                                          |        1 |
| Schweigger, A. F.                                   |        1 |
| Niemelä, J.                                         |        1 |
| Kaczmarek, W.                                       |        1 |
| Boulton, A. M.                                      |        1 |
| Reimer, N. J.                                       |        1 |
| Mallis, A.                                          |        1 |
| Deichmüller, J. V.                                  |        1 |
| Baden, R.                                           |        1 |
| Ovazza, M.                                          |        1 |
| Kostjuk, J. A.                                      |        1 |
| Garling, L.                                         |        1 |
| Watanasit, S.                                       |        1 |
| Rotramel, G. L.                                     |        1 |
| Hôzawa, S.                                          |        1 |
| Eilmus, S.                                          |        1 |
| Berland, L.                                         |        1 |
| Taschenberg, E. L.                                  |        1 |
| Popp, M. P.                                         |        1 |
| Torgerson, R. L.                                    |        1 |
| Lokkers, C.                                         |        1 |
| Gunawardene, N. R.                                  |        1 |
| Andersson, B.                                       |        1 |
| Nuhn, T. P.                                         |        1 |
| Kern, F.                                            |        1 |
| François, J.                                        |        1 |
| Vernalha, M. M.                                     |        1 |
| Ritter, H.                                          |        1 |
| Martini, R.                                         |        1 |
| Heuer, H. G.                                        |        1 |
| Bass, J. A.                                         |        1 |
| Street, M. D.                                       |        1 |
| Passerin d'Entrèves, P.                             |        1 |
| Kupianskaya, A. N.                                  |        1 |
| Ghigi, A.                                           |        1 |
| Wenner, A. M.                                       |        1 |
| Samson, D. A.                                       |        1 |
| Moya, J.                                            |        1 |
| Jäch, M. A.                                         |        1 |
| Nascimento, I. C.                                   |        1 |
| Jekel, H.                                           |        1 |
| Fernández-Marín, H.                                 |        1 |
| Boieiro, M. R. C.                                   |        1 |
| Tsyubik, M. M.                                      |        1 |
| Ranta, E.                                           |        1 |
| Daloze, D.                                          |        1 |
| Arthofer, W.                                        |        1 |
| Buhs, J. B.                                         |        1 |
| Volny, V. P.                                        |        1 |
| Rojas-Fernández, P.                                 |        1 |
| Höfener, C.                                         |        1 |
| Bedziak, I.                                         |        1 |
| Sumner, S.                                          |        1 |
| Petrulevicius, J. F.                                |        1 |
| Law, J. H.                                          |        1 |
| Godden, C.                                          |        1 |
| Widodo, E. S.                                       |        1 |
| Abdul-Rassoul, M. S.                                |        1 |
| Schneider, J. S.                                    |        1 |
| Gotzek, D.                                          |        1 |
| Würmli, M.                                          |        1 |
| Albrecht, A.                                        |        1 |
| Scott, H.                                           |        1 |
| Niemeyer, H.                                        |        1 |
| Kaplin, V. G.                                       |        1 |
| Flores-Maldonado, K. Y.                             |        1 |
| Reis, Y. T.                                         |        1 |
| Baggini, A.                                         |        1 |
| Sposito, E. C.                                      |        1 |
| Pace, R.                                            |        1 |
| Kotzias, H.                                         |        1 |
| Garraffo, H. M.                                     |        1 |
| Camilo, G. R.                                       |        1 |
| Waterhouse, F. H.                                   |        1 |
| Rüger, M. H.                                        |        1 |
| Hsu, S.-L.                                          |        1 |
| Ellison, A. M.                                      |        1 |
| Berman, D. I.                                       |        1 |
| Tegelström, H.                                      |        1 |
| Potts, R. W. L.                                     |        1 |
| Levins, R.                                          |        1 |
| Bitsch, J.                                          |        1 |
| Torre-Grossa, J. P.                                 |        1 |
| Quiroz-Robledo, L.                                  |        1 |
| Lombarte, A.                                        |        1 |
| Gundlach, J.                                        |        1 |
| Zhou S. Y.                                          |        1 |
| Singleton, J.                                       |        1 |
| Nunes, P. H.                                        |        1 |
| Kevan, D. K. McE                                    |        1 |
| Frank, S. R.                                        |        1 |
| Brill, J. H.                                        |        1 |
| Rittler, H.                                         |        1 |
| Hilburn, D. J.                                      |        1 |
| Diehl, E.                                           |        1 |
| Strickland, A. H.                                   |        1 |
| Ghilarov, M. S.                                     |        1 |
| Jaeger, E.                                          |        1 |
| Faulds, W.                                          |        1 |
| Schneider, L. C.                                    |        1 |
| Nascimento, I. C. do                                |        1 |
| Jiménez Rojas, J.                                   |        1 |
| Ferrer, J.                                          |        1 |
| Tuff, D. W.                                         |        1 |
| Raqué, K.-F.                                        |        1 |
| Lude, A.                                            |        1 |
| Halverson, D. D.                                    |        1 |
| Omelchenko, L. V.                                   |        1 |
| Knaden, M.                                          |        1 |
| Funakubo, H.                                        |        1 |
| Bünzli, G. H.                                       |        1 |
| von Aesch, L.                                       |        1 |
| Rojas, P.                                           |        1 |
| Mescher, M. C.                                      |        1 |
| Dunn, R. R.                                         |        1 |
| Behr, D.                                            |        1 |
| Picquet, N.                                         |        1 |
| Leclerc, J.                                         |        1 |
| Chenuil, A.                                         |        1 |
| Abensperg-Traun, M.                                 |        1 |
| Lewis, S. E,                                        |        1 |
| Cohic, F.                                           |        1 |
| Yamamoto, M.-T.                                     |        1 |
| Albrecht, M.                                        |        1 |
| Seevers, C. H.                                      |        1 |
| Nikitin, M. I.                                      |        1 |
| Kappel, A. W.                                       |        1 |
| Bowley, D. R.                                       |        1 |
| Vanni, S.                                           |        1 |
| Heil, M.                                            |        1 |
| Delage, B.                                          |        1 |
| Padilla, R. C.                                      |        1 |
| Gartner, I.                                         |        1 |
| Camlitepe, Y.                                       |        1 |
| Watson, E. M.                                       |        1 |
| Monastero, S.                                       |        1 |
| Elton, E. T. G.                                     |        1 |
| Theobald-Ley, S.                                    |        1 |
| Pressick, M. L.                                     |        1 |
| Torres-Contreras, H.                                |        1 |
| Gunsalam, G.                                        |        1 |
| Crowson, R. A.                                      |        1 |
| Zientz, E.                                          |        1 |
| Andrewes, H. E.                                     |        1 |
| Sitthicharoenchai, D.                               |        1 |
| Kholová, H.                                         |        1 |
| Veuille, M.                                         |        1 |
| Robson, S. K. A.                                    |        1 |
| Hincapié, C.                                        |        1 |
| Dietemann, V.                                       |        1 |
| Basulati, K. K.                                     |        1 |
| Paul, J.                                            |        1 |
| Gillespie, D. S.                                    |        1 |
| Carvalho, A. O. R. de                               |        1 |
| Sanderson, M. W.                                    |        1 |
| Mulsant, E.                                         |        1 |
| Jaennicke, F.                                       |        1 |
| Febvay, G.                                          |        1 |
| Bonavita-Cougourdan, A.                             |        1 |
| Tynes, J. S.                                        |        1 |
| Räsänen, V.                                         |        1 |
| Hamaguchi, K.                                       |        1 |
| Athias-Henriot, C.                                  |        1 |
| Sörensen, U.                                        |        1 |
| Orivel, J.                                          |        1 |
| Knauer, F.                                          |        1 |
| Burgman, M. A.                                      |        1 |
| Von Sicard, N. A. E.                                |        1 |
| Roma, G. C.                                         |        1 |
| Meyne, J.                                           |        1 |
| Högmo, O.                                           |        1 |
| Dunton, R. F.                                       |        1 |
| Suñer i Escriche, D.                                |        1 |
| Piek, T.                                            |        1 |
| Leclercq, S.                                        |        1 |
| Goll, W.                                            |        1 |
| Wiernasz, D. C.                                     |        1 |
| Abouheif, E.                                        |        1 |
| Liebig, J.                                          |        1 |
| Grasso, D. A.                                       |        1 |
| Colina, G. O.                                       |        1 |
| Yamamoto, T.                                        |        1 |
| Aldana de la Torre, R. C.                           |        1 |
| Seima, F. A.                                        |        1 |
| Nilsson, O.                                         |        1 |
| Karpinski, J. J.                                    |        1 |
| Fonseca, C. R. F.                                   |        1 |
| Bown, T. M.                                         |        1 |
| Vargo, E. L.                                        |        1 |
| Mamaev, B. M.                                       |        1 |
| Delfino, M. A.                                      |        1 |
| Stainforth, T.                                      |        1 |
| Kremer, G.                                          |        1 |
| Gateva, R.                                          |        1 |
| Watt, A. D.                                         |        1 |
| Russell, J. A.                                      |        1 |
| Monnin, T.                                          |        1 |
| Englisch, T.                                        |        1 |
| Beshers, S. N.                                      |        1 |
| Blades, D. A.                                       |        1 |
| Lopes, B. C.                                        |        1 |
| Gurgel-Gonçalves, R.                                |        1 |
| Zíkan, W.                                           |        1 |
| Angus, C. J.                                        |        1 |
| Skaife, S. H.                                       |        1 |
| Oberstadt, B.                                       |        1 |
| Khomenko, V. N.                                     |        1 |
| Freitag, A.                                         |        1 |
| Roche, R. K.                                        |        1 |
| McGlynn, T. P.                                      |        1 |
| Hinkle, G.                                          |        1 |
| Diffie, S.                                          |        1 |
| Baugnée, J. Y.                                      |        1 |
| Stummer, A.                                         |        1 |
| Pavon, L. F.                                        |        1 |
| La Rivers, I.                                       |        1 |
| Giovannotti, M.                                     |        1 |
| Carvalho, K. S.                                     |        1 |
| Werringloer, A.                                     |        1 |
| Sartori, M.                                         |        1 |
| Jagodzinska, Z.                                     |        1 |
| Schoenherr, C. J.                                   |        1 |
| Nascimento, R. R. do, Schoeters, E.                 |        1 |
| Jonkman, J. C. M.                                   |        1 |
| Fiala, J.                                           |        1 |
| Bond, W.                                            |        1 |
| Übler, E.                                           |        1 |
| Rastogi, N.                                         |        1 |
| Lutinski, J. A.                                     |        1 |
| De Carli, P.                                        |        1 |
| Soroker, V.                                         |        1 |
| Orr, M. R.                                          |        1 |
| Gahl, H.                                            |        1 |
| Burton, J. L.                                       |        1 |
| Vowles, D. M.                                       |        1 |
| Romand, B. E. de                                    |        1 |
| Hohorst, B.                                         |        1 |
| Düssmann, O.                                        |        1 |
| Suñer, D.                                           |        1 |
| Pietrantonio, P. V.                                 |        1 |
| Gómez Aval, K.                                      |        1 |
| Procter, W.                                         |        1 |
| Colombel, P.                                        |        1 |
| Yasuno, M.                                          |        1 |
| Nipperess, D. A.                                    |        1 |
| Kaschef, A. H.                                      |        1 |
| Børgesen, L. W.                                     |        1 |
| Reyes López, J.                                     |        1 |
| Mamet, R.                                           |        1 |
| Hemming, F.                                         |        1 |
| Detrain, C.                                         |        1 |
| Baiocco, L. M.                                      |        1 |
| Stankiewicz, A. M.                                  |        1 |
| Palenitschko, Z. G.                                 |        1 |
| Gavrilov, K.                                        |        1 |
| Watts, C. H. S.                                     |        1 |
| Russell, W. E.                                      |        1 |
| Esben-Petersen, P.                                  |        1 |
| Bestelmayer, B. T.                                  |        1 |
| Theunert, R.                                        |        1 |
| Felisberti, F.                                      |        1 |
| Blard, F.                                           |        1 |
| Trivers, R. L.                                      |        1 |
| Rabitsch, W.                                        |        1 |
| Lopes, H. S.                                        |        1 |
| Gusmão, L. G.                                       |        1 |
| Antsiferov, V. M.                                   |        1 |
| Obin, M. S.                                         |        1 |
| Khoo, Y. H.                                         |        1 |
| Freitas, A. V. L.                                   |        1 |
| Bruder, K. W.                                       |        1 |
| Viginier, B.                                        |        1 |
| Rockwood, L. L.                                     |        1 |
| McGurk, D. J.                                       |        1 |
| Hinton, H. E.                                       |        1 |
| Sturm, J.                                           |        1 |
| Labuda, M.                                          |        1 |
| Westhoff, V.                                        |        1 |
| Sauer, C.                                           |        1 |
| Munroe, P. D.                                       |        1 |
| Jahyny, B.                                          |        1 |
| Wilkinson, R. C.                                    |        1 |
| Nefedov, N. I.                                      |        1 |
| Jordan, K. H. C.                                    |        1 |
| Fiebrig, K.                                         |        1 |
| Bonetto, A. A.                                      |        1 |
| Ratchford, J. S.                                    |        1 |
| Sorvari, J.                                         |        1 |
| Ortius-Lechner, D.                                  |        1 |
| Knudtson, B. K.                                     |        1 |
| Bution, M. L.                                       |        1 |
| Ronquist, F.                                        |        1 |
| Minkiewicz, R.                                      |        1 |
| Eastlake Chew, A.                                   |        1 |
| Belin-Depoux, M.                                    |        1 |
| Sunil Kumar, M.                                     |        1 |
| Pignalberi, C. T.                                   |        1 |
| Leech, H. B.                                        |        1 |
| Chhotani, D.                                        |        1 |
| Griep, E.                                           |        1 |
| Conklin, A.                                         |        1 |
| York, A.                                            |        1 |
| Nolan, E. J. (ed.)                                  |        1 |
| Kasugai, M.                                         |        1 |
| Forskål, P.                                         |        1 |
| Hennig, W.                                          |        1 |
| Devi, C. M.                                         |        1 |
| Baldridge, R. S.                                    |        1 |
| Starr, C. K.                                        |        1 |
| Palma, R. L.                                        |        1 |
| Krishna Ayyar, P. N.                                |        1 |
| Gehring, W. J.                                      |        1 |
| Cammell, M. E.                                      |        1 |
| Way, M. J.                                          |        1 |
| Morais, H. C.                                       |        1 |
| Imanishi, K.                                        |        1 |
| Thorne, B. L.                                       |        1 |
| Blatrix, R.                                         |        1 |
| Trojan, P.                                          |        1 |
| Ragonot, E. L.                                      |        1 |
| López Moreno, I. R.                                 |        1 |
| Haak, U.                                            |        1 |
| Zittser, T. V.                                      |        1 |
| Apostolov, L. G.                                    |        1 |
| Ochi, K.                                            |        1 |
| Kidd, L. N.                                         |        1 |
| Fritzsche, R.                                       |        1 |
| Brühl, C.                                           |        1 |
| Vilela, E. F.                                       |        1 |
| McInnes, D. A.                                      |        1 |
| Hirano, I.                                          |        1 |
| Lachaud, J. P.                                      |        1 |
| Gladstone, D. E.                                    |        1 |
| Casolari, C.                                        |        1 |
| Saux, C.                                            |        1 |
| Jaitrong, W.                                        |        1 |
| Chhotani, O. B.                                     |        1 |
| Wisdom, W. A.                                       |        1 |
| Addison, P.                                         |        1 |
| Schön, A.                                           |        1 |
| Fielde, A. M.                                       |        1 |
| Borcard, Y.                                         |        1 |
| Ratsirarson, H.                                     |        1 |
| Macaranas, J. M.                                    |        1 |
| Hansen, S. R.                                       |        1 |
| De Menten, L.                                       |        1 |
| Auel, H.                                            |        1 |
| Soto, S. U.                                         |        1 |
| Ortius, D.                                          |        1 |
| Koen, J. H.                                         |        1 |
| Holt, J. A.                                         |        1 |
| Eastwood, R.                                        |        1 |
| Bellas, T.                                          |        1 |
| Pogorevici, N.                                      |        1 |
| Lefeber, B. A.                                      |        1 |
| González Pérez, J. L.                               |        1 |
| Groc, S.                                            |        1 |
| Corn, M. L.                                         |        1 |
| Allies, A. B.                                       |        1 |
| Seyma, F. A.                                        |        1 |
| Nomura, K.                                          |        1 |
| Kautz, S.                                           |        1 |
| Forsyth, A.                                         |        1 |
| Rhoades, R. B.                                      |        1 |
| Henshaw, M. T.                                      |        1 |
| Barquín, J.                                         |        1 |
| Stawarski, I.                                       |        1 |
| Kroyer, H. N.                                       |        1 |
| Gerlach, J.                                         |        1 |
| Campiolo, S.                                        |        1 |
| Weir, J. S.                                         |        1 |
| Safford, W. E.                                      |        1 |
| Moreira, D. D. O.                                   |        1 |
| Espelie, K. E.                                      |        1 |
| Timmins, C. J.                                      |        1 |
| Feller, C.                                          |        1 |
| Trontti, K.                                         |        1 |
| Ramdas Menon, M. G.                                 |        1 |
| López-Moreno, I. R.                                 |        1 |
| Hacobian, B. S.                                     |        1 |
| Cupul-Magañ, F. G.                                  |        1 |
| Zorilla, J. M.                                      |        1 |
| Araujo, M. S.                                       |        1 |
| Sledge, M. F.                                       |        1 |
| Oeser, R.                                           |        1 |
| Kidd, M. G.                                         |        1 |
| Fröhlich, C.                                        |        1 |
| Brühl, C. A.                                        |        1 |
| Rodriguez-Garza, J. A.                              |        1 |
| Hirosawa, H.                                        |        1 |
| Dobrzanski, J.                                      |        1 |
| Bausenwein, F.                                      |        1 |
| Suchocka, H.                                        |        1 |
| Penev, S.                                           |        1 |
| Laeger, T.                                          |        1 |
| Scheffrahn, R. H.                                   |        1 |
| Musthak Ali, T. M.                                  |        1 |
| Jakubisiak, S.                                      |        1 |
| Woinarski, J. C. Z.                                 |        1 |
| Adeli, E.                                           |        1 |
| Negrobov, O. P.                                     |        1 |
| Jørum, P.                                           |        1 |
| Borchert, H. F.                                     |        1 |
| Réaumur, R. A. F. de                                |        1 |
| MacArthur, R. H.                                    |        1 |
| Debaisieux, P.                                      |        1 |
| Ayala, F. J.                                        |        1 |
| Souza Paula, H.                                     |        1 |
| Oster, G. F.                                        |        1 |
| Ganglbauer, L.                                      |        1 |
| Caesar, C. J.                                       |        1 |
| Waldkircher, G.                                     |        1 |
| Roonwal, M. L.                                      |        1 |
| Miradoli Zatti, M. A.                               |        1 |
| Holway, D.                                          |        1 |
| Echols, H. W.                                       |        1 |
| Benois, A.                                          |        1 |
| Swainson W.                                         |        1 |
| Pollock, G. B.                                      |        1 |
| Gonzalez Villareal, D.                              |        1 |
| Pusvaskyte, O.                                      |        1 |
| Coronado Padilla, R.                                |        1 |
| Sharplin, J.                                        |        1 |
| Kawahara, Y.                                        |        1 |
| Foucaud, J.                                         |        1 |
| Breed, M. D.                                        |        1 |
| Vepsäläinen K.                                      |        1 |
| Ribas, C. R.                                        |        1 |
| Dewitz, H.                                          |        1 |
| Bart, K. M.                                         |        1 |
| Stein, M. B.                                        |        1 |
| Paramonov, S. Y.                                    |        1 |
| Kula, E.                                            |        1 |
| Carbonell Mas, C. S.                                |        1 |
| Weiser, M. D.                                       |        1 |
| Sáiz, F.                                            |        1 |
| Estrada M. C.                                       |        1 |
| Bhatkar, A. P.                                      |        1 |
| Blüthgen, P.                                        |        1 |
| Troppmair, H.                                       |        1 |
| Rammoser, H.                                        |        1 |
| Haddow, A. J.                                       |        1 |
| Daguerre, J. B.                                     |        1 |
| Zylberberg, L.                                      |        1 |
| Arias P., T. M.                                     |        1 |
| Ohl, M.                                             |        1 |
| Brun, L. O.                                         |        1 |
| Visicchio, R.                                       |        1 |
| Hites, N. L.                                        |        1 |
| Peregrine, D. J.                                    |        1 |
| Laine, K. J.                                        |        1 |
| Catangui, M. A.                                     |        1 |
| Scheurer, S.                                        |        1 |
| Na, J. P. S.                                        |        1 |
| Wollmann, K.                                        |        1 |
| Adolph, G. E.                                       |        1 |
| Schrempf, A.                                        |        1 |
| Nelmes, E.                                          |        1 |
| Jucci, C.                                           |        1 |
| Flanders, S. E.                                     |        1 |
| van der Hammen, T.                                  |        1 |
| Reder, E.                                           |        1 |
| MacConnell, J. G.                                   |        1 |
| Hauck, V.                                           |        1 |
| Deblauwe, I.                                        |        1 |
| Ayre, G. L.                                         |        1 |
| Spagna, J. C.                                       |        1 |
| Österreichischen Gesellschaft für Ameisenkunde      |        1 |
| Kogure, T.                                          |        1 |
| García-Pérez, J. A.                                 |        1 |
| Caldas, A.                                          |        1 |
| Wardlaw, J. C.                                      |        1 |
| Missa, O.                                           |        1 |
| Eckert, J. E.                                       |        1 |
| Bentley, B. L.                                      |        1 |
| Leprince, D. J.                                     |        1 |
| Tokunaga, M.                                        |        1 |
| Queiroz, M. V. B.                                   |        1 |
| Lobry de Bruyn, L. A.                               |        1 |
| Grutzmacher, D. D.                                  |        1 |
| Corrêa, M. M.                                       |        1 |
| Zara, F. J.                                         |        1 |
| Shen, L.                                            |        1 |
| Nowbahari, E.                                       |        1 |
| Breen, J.                                           |        1 |
| Rice, H. M. A.                                      |        1 |
| Marinho C. G. S.                                    |        1 |
| Hertlein, L. G.                                     |        1 |
| Dey, D.                                             |        1 |
| Barth, R.                                           |        1 |
| Steinwarz, D.                                       |        1 |
| Pardo Vargas, R.                                    |        1 |
| Kumar, R.                                           |        1 |
| Gertsch, P.                                         |        1 |
| Carlton, C. E.                                      |        1 |
| Járdán, C.                                          |        1 |
| Bode, E.                                            |        1 |
| Ramos Lacau, L. de S.                               |        1 |
| Sobrinho, T. G.                                     |        1 |
| Ohnishi, H.                                         |        1 |
| Frumhoff, P. C.                                     |        1 |
| Viswanath, B. N.                                    |        1 |
| Rögener, J.                                         |        1 |
| Mehlhop, P.                                         |        1 |
| Hoare, R. J. B.                                     |        1 |
| Doums, C.                                           |        1 |
| Suehiro, A.                                         |        1 |
| LaMon, B.                                           |        1 |
| Glöckner, W. E.                                     |        1 |
| Whiting, J. H., Jr.                                 |        1 |
| Schilder, K.                                        |        1 |
| Chujo, M.                                           |        1 |
| Woodall, P. F.                                      |        1 |
| Schug, A.                                           |        1 |
| Netshilaphala, N. M.                                |        1 |
| Julian, G. E.                                       |        1 |
| Fletcher, D. J. C.                                  |        1 |
| Bot, A. N. M.                                       |        1 |
| Van der Have, T. M.                                 |        1 |
| Debouge, M.H.                                       |        1 |
| Spangler, H. G.                                     |        1 |
| Oswald, J. D.                                       |        1 |
| Kohn, M.                                            |        1 |
| García, M.                                          |        1 |
| Callcott, A.-M. A.                                  |        1 |
| Ware, A. B.                                         |        1 |
| Rossbach, M. H.                                     |        1 |
| Mitroshina, L. A.                                   |        1 |
| Hopkinson, J.                                       |        1 |
| Eder, J.                                            |        1 |
| Poole, R. W.                                        |        1 |
| Lessard, J.-P.                                      |        1 |
| Gorman, J. S. T.                                    |        1 |
| Tonapi, G. T.                                       |        1 |
| Quek, S. P.                                         |        1 |
| Lofgren, C. S.                                      |        1 |
| Guilbert, E.                                        |        1 |
| Coulon, L.                                          |        1 |
| Zayas, L.                                           |        1 |
| Almeida Toledo, L. F. de                            |        1 |
| Shindo, M.                                          |        1 |
| Keister, M.                                         |        1 |
| Fraga, N. J.                                        |        1 |
| Verdinelli, M.                                      |        1 |
| Márquez Luna, J.                                    |        1 |
| Hespenheide, H. A.                                  |        1 |
| Díaz Azpiazu, M.                                    |        1 |
| Bartz, S. H.                                        |        1 |
| Stolpe, H.                                          |        1 |
| Pardo, X.                                           |        1 |
| Kume, S.                                            |        1 |
| Gertsch, P. J.                                      |        1 |
| Carney, W. P.                                       |        1 |
| Salvarani, A.                                       |        1 |
| Iredale, T.                                         |        1 |
| Fabres, G.                                          |        1 |
| Bier, K.                                            |        1 |
| Jeanne, R. L.                                       |        1 |
| Fenger, H.                                          |        1 |
| Bogoescu, C.                                        |        1 |
| Tshiguvho, T. E.                                    |        1 |
| Ramos-Elorduy de Conconi, J.                        |        1 |
| Dalecky, A.                                         |        1 |
| Somfai, E.                                          |        1 |
| Fuentes, J. E.                                      |        1 |
| Brunnert, A.                                        |        1 |
| Vogelsanger, E.                                     |        1 |
| Rohlfien, K.                                        |        1 |
| Meinwald, J.                                        |        1 |
| Hocking, B.                                         |        1 |
| Dubey, A.K.                                         |        1 |
| Beck, D. E.                                         |        1 |
| Sugerman, B. B.                                     |        1 |
| Péru, L.                                            |        1 |
| Lanne, B. S.                                        |        1 |
| Glover, P. E.                                       |        1 |
| Whiting, P. W.                                      |        1 |
| Schilliger, E.                                      |        1 |
| Nakamura, N.                                        |        1 |
| Ahmad, M. M. G.                                     |        1 |
| Schwander, T.                                       |        1 |
| Floater, G. J.                                      |        1 |
| Botes, A.                                           |        1 |
| van Hamburg, H.                                     |        1 |
| Reimer, N.                                          |        1 |
| Magalhães, L. E. de                                 |        1 |
| Hazeltine, W. F.                                    |        1 |
| Degnan, P. H.                                       |        1 |
| Baba, Y.                                            |        1 |
| Sparks, S. D.                                       |        1 |
| Ouellette, G. D.                                    |        1 |
| Kôno, H.                                            |        1 |
| Gardner, W.                                         |        1 |
| Calvert, P. P.                                      |        1 |
| Warren, L. O.                                       |        1 |
| Rossi de Garcia, E.                                 |        1 |
| Miyata, H.                                          |        1 |
| Hosking, A. C.                                      |        1 |
| Takechi, F.                                         |        1 |
| Popovici-Baznosanu, A.                              |        1 |
| Lokay, E.                                           |        1 |
| Guittini, U.                                        |        1 |
| Coyle, F. A.                                        |        1 |
| Zdobnitzky, W.                                      |        1 |
| Amstutz, M. E.                                      |        1 |
| Noyce, K. V.                                        |        1 |
| Franch, J.                                          |        1 |
| Brener, A. G. F.                                    |        1 |
| Vergara Navarro, E. V.                              |        1 |
| Ríos-Casanova, L.                                   |        1 |
| Martínez-Ibáñez, M. D.                              |        1 |
| Hess, C. G.                                         |        1 |
| Parfitt, E.                                         |        1 |
| Kümmerli, R.                                        |        1 |
| Gestro, R.                                          |        1 |
| Carpintero Ortega, S.                               |        1 |
| Fadini, M. A. M.                                    |        1 |
| Bigot, Y.                                           |        1 |
+-----------------------------------------------------+----------+
931 rows in set (0.06 sec)
