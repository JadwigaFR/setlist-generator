class Artist < ApplicationRecord
  has_many :albums

  nilify_blanks :before => :create
end
