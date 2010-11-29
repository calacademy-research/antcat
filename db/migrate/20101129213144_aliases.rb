class Aliases < ActiveRecord::Migration
  def self.up
    AuthorName.transaction do

      AuthorName.correct "Diaz Bitancourt, M. E.", "Diaz Betancourt, M. E."
      AuthorName.correct "Taylor, R.W.", "Taylor, R. W."

      author = AuthorName.find_by_name('MacKay, W. P.').author
      lowercase_w_p = AuthorName.create! :author => author, :name => 'Mackay, W. P.'
      lowercase_w = AuthorName.create! :author => author, :name => 'Mackay, W.'

      ['96-1862', 
      '96-1853', 
      '96-0996', 
      '96-0582', 
      '96-1298', 
      '96-0456', 
      '96-0457', 
      '96-0581', 
      '96-1095', 
      '96-0759', 
      '96-1912', 
      '96-1878', 
      '96-1809', 
      '96-0997', 
      '96-0158', 
      '96-0448', 
      '96-0998', 
      '96-1252', 
      '96-1002',].each do |cite_code|
        Reference.find_by_cite_code(cite_code).replace_author_name('MacKay, W. P.', lowercase_w_p)
      end

      ['96-1877', 
      '96-1789', 
      '96-0780', 
      '96-0999', 
      '96-1645', 
      '96-1954',].each do |cite_code|
        Reference.find_by_cite_code(cite_code).replace_author_name('MacKay, W.', lowercase_w)
      end
    end
  end

  def self.down
  end
end
