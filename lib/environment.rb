# coding: UTF-8
class Environment 
  def initialize server = :production
    @server = server.try :to_sym
  end

  def production?; @server = :production end
  def preview?; @server = :preview end

  def user_can_edit_references? user
    user_is_editor? user
  end

  def user_can_edit_catalog? user
    user_is_editor? user
  end

  def user_is_editor? user
    user || sandbox?
  end

  def previewize string
    return string + ' (preview)' if preview?
    string
  end

  def self.create
    contents = read_server_config_file
    case contents
    when 'preview'
      SandboxEnvironment.new contents
    else
      ProductionEnvironment.new contents
    end
  end

  def self.read_server_config_file
    directory = Rails.env.production? ? '/data/antcat/shared/config/' : Rails.root + 'config/'
    file_name = "#{directory}/server.config"
    File.read file_name rescue nil
  end

end

class ProductionEnvironment < Environment
  def sandbox?; false; end
  def restricted?; true; end

  def title; 'AntCat' end
  def can_upload_pdfs?; true end
end

class PreviewEnvironment < Environment
  def sandbox?; true; end
  def restricted?; false; end

  def title; 'Preview of AntCat' end
  def can_upload_pdfs?; false end
end

$Environment = Environment.create
