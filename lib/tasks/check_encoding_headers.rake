# coding: UTF-8
#From http://snaprails.tumblr.com/post/556378216/porting-an-application-to-ruby-1-9

desc "Manage the encoding header of Ruby files"
task :check_encoding_headers do
  files = Array.new
  ["*.rb", "*.rake"].each do |extension|
    files.concat(Dir[ File.join(Dir.getwd.split(/\\/), "**", extension) ])
  end

  files.each do |file|
    content = File.read(file)
    next if content[0..16] == "# coding: UTF-8\n"
    
    ["\n\n", "\n"].each do |file_end|
      content = content.gsub(/(# encoding: UTF-8#{file_end})|(# coding: UTF-8#{file_end})|(# -*- coding: UTF-8 -*-#{file_end})/i, "")
    end

    new_file = File.open(file, "w")
    new_file.write("# coding: UTF-8\n"+content)
    new_file.close
  end
end
