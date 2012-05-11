# coding: UTF-8

desc "Upload PDFs and point references to them"
task :upload_pdfs => :environment do

  pdf_location = Rails.root + 'data/pdfs'
  for pdf in Dir.glob pdf_location + '*.pdf'
    key = File.basename pdf, '.pdf'
    puts "Looking for document for " + key
    reference_document = ReferenceDocument.where("url LIKE '%/#{key}.pdf'").first
    unless reference_document
      puts "Didn't find it"
      next
    end
    puts reference_document
    File.open pdf do |file|
      reference_document.file = file
      reference_document.save! 
      reference_document.host = 'antcat.org'
    end
    reference_document.reload
    puts reference_document
  end

end
