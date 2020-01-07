class SoftValidationDecorator < Draper::Decorator
  delegate :runtime

  def format_runtime
    ms = runtime * 1000
    "#{ms.round} ms"
  end

  def format_runtime_percent total_runtime
    percent = (runtime / total_runtime) * 100
    "#{percent.round(2)}%"
  end
end
