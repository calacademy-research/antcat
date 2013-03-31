# coding: UTF-8
class Environment 
  def initialize server = nil
    server = :local if server.nil? and Rails.env.test?
    @server = server.try(:to_sym) || :production
  end

  def production?; @server == :production end
  def preview?;    @server == :preview end

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
      RestrictedEnvironment.new contents
    end
  end

  def self.read_server_config_file
    directory = Rails.env.production? ? '/data/antcat/shared/config/' : Rails.root + 'config/'
    file_name = "#{directory}/server.yml"
    YAML.load_file file_name
  end

end

class RestrictedEnvironment < Environment
  def sandbox?; false; end

  def title; 'AntCat' end
  def can_upload_pdfs?; true end

  def user_is_editor? user
    user
  end

  def user_can_edit_references? user
    user
  end

  def user_can_edit_catalog? user
    user && user.can_edit_catalog?
  end

end

class SandboxEnvironment < Environment
  def sandbox?; true; end

  def title; 'Preview of AntCat' end
  def can_upload_pdfs?; false end

  def user_is_editor? user
    true
  end

  def user_can_edit_references? _
    true
  end

  def user_can_edit_catalog? _
    true
  end

end

$Environment = Environment.create
