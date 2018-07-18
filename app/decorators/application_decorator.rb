class ApplicationDecorator < Draper::Decorator
  def get_current_user
    helpers.current_user
  rescue NoMethodError
    nil
  end
end
