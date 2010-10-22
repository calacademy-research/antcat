module UniqueFilename
  def self.get directory, name
    ext = File.extname name
    basename = File.basename name, ext
    basename = basename.gsub(/\s/, '_').gsub(/[^\w\._]/, '')

    index = 0
    newname = basename + ext
    while File.exist? File.join directory + newname
      index += 1
      suffix = "_#{index}"
      newname = basename + suffix + ext
    end
    newname
  end
end
