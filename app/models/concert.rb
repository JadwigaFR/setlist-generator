class Concert < ApplicationRecord
  belongs_to :artist
  belongs_to :venue

  has_many :setlists
  # Add validation that the artist venue and date cannot be twice the same combinaison to avoid duplicates
end
