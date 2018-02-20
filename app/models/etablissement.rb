# ADD constants about nature_mise_a_jour out of commercial diffusion for better simplicity

class Etablissement < ApplicationRecord
  attr_accessor :csv_path

  searchable do
    text :nom_raison_sociale
    text :libelle_activite_principale_entreprise
    text :libelle_commune
    text :l4_normalisee
    string :activite_principale
    string :code_postal
    string :nature_mise_a_jour
    string :is_ess
    string :nature_entrepreneur_individuel
    string :statut_prospection
    string :tranche_effectif_salarie_entreprise
    string :enseigne
  end

  def self.latest_mise_a_jour
    latest_entry.try(:date_mise_a_jour)
  end

  def self.latest_entry
    limit(1).order('date_mise_a_jour DESC').first
  end
end
