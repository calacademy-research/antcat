# frozen_string_literal: true

class AddGenderAgreementTypeToProtonyms < ActiveRecord::Migration[6.0]
  def change
    add_column :protonyms, :gender_agreement_type, :string
  end
end
