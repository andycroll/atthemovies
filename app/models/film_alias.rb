class FilmAlias < ApplicationRecord
  MARKS = /[™®©]/
  APOSTROPHES = /['’]/
  LEADING_THE = /\Athe /

  belongs_to :film
  before_validation { self.normalized_name = self.class.normalize(name) }
  validates :name, :normalized_name, presence: true

  def self.normalize(name)
    plain = name.to_s.gsub(MARKS, "").unicode_normalize(:nfkd).gsub(/\p{Mn}/, "").downcase
    plain = plain.gsub("&", " and ").gsub(APOSTROPHES, "")
    plain.gsub(/[^\p{Alnum}]+/, " ").strip.sub(LEADING_THE, "")
  end
end
