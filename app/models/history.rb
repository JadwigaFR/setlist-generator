class History < ApplicationRecord
  belongs_to :concert
  belongs_to :user
end
