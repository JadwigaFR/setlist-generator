class Setlist < ApplicationRecord
  belongs_to :concert
  belongs_to :song
  delegate :name, to: :song
end
