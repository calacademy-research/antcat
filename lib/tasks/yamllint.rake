# frozen_string_literal: true

desc "Run yamllint"
task :yamllint do
  sh "yamllint -c .yamllint ."
end
