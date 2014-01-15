# coding: UTF-8
desc "Copy PDFs from CAS to local"
task copy_pdfs: :environment do
  pdfs = []
  Progress.new_init show_progress: true, total_count: 4672
  Dir.glob '/Volumes/data/informatics/AntCat/AntBase/ants/publications/*' do |directory_name|
    next unless File.basename(directory_name) =~ /^\d/
    Dir.glob "#{directory_name}/*" do |file_name|
      next unless File.basename(file_name) =~ /^[^_]+\.pdf$/
      `cp '#{file_name}' '/Users/mwilden/antcat/data/pdfs'`
      raise unless $?.success?
      Progress.tally_and_show_progress 1
    end
  end
  Progress.show_results
end

desc "Upload PDFs from local to S3 and update references"
task upload_pdfs: :environment do
  unfound_pdfs = []
  pdfs = Dir.glob Rails.root + 'data/pdfs/*.pdf'
  Progress.new_init show_progress: true, total_count: pdfs.size
  pdfs.each do |pdf|
    unless ReferenceDocument.upload_antbase_pdf pdf
      unfound_pdfs << File.basename(pdf)
    end
    Progress.tally_and_show_progress 1
  end
  puts unfound_pdfs
  Progress.puts "#{unfound_pdfs.count} references not found"
  Progress.show_results
end
