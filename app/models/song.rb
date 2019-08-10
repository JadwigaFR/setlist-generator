class Song < ApplicationRecord
  belongs_to :album, optional: true
  delegate :date, to: :album
end
