class ExternalIdentifier < ApplicationRecord
  belongs_to :identifiable, polymorphic: true
  validates :source, :value, presence: true
end
