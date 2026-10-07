class FilmAlias < ApplicationRecord
  belongs_to :film
  before_validation { self.normalized_name = self.class.normalize(name) }
  validates :name, :normalized_name, presence: true

  def self.normalize(name)
    name.to_s.unicode_normalize(:nfkc).downcase.gsub(/[^\p{Alnum}]+/, " ").strip
  end
end
