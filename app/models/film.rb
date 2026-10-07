class Film < ApplicationRecord
  has_secure_token :public_id
  attr_readonly :public_id
  has_many :external_identifiers, as: :identifiable, dependent: :destroy
  has_many :film_aliases, dependent: :destroy
  has_many :tmdb_candidates, dependent: :destroy
  has_many :performances, dependent: :destroy
  has_many :cinemas, -> { distinct }, through: :performances
  has_one_attached :poster do |attachable|
    attachable.variant :listing, resize_to_limit: [ 400, 600 ]
  end
  has_one_attached :backdrop
  validates :name, presence: true
  validates :poster_source_url, :backdrop_source_url, format: { with: %r{\Ahttps://image\.tmdb\.org/t/p/(original|w\d+)/[a-zA-Z0-9]+\.(jpg|png)\z} }, allow_blank: true
  validate do
    %i[poster backdrop].each do |kind|
      image = public_send(kind)
      errors.add(kind, "must be a JPEG, PNG or WebP image") if image.attached? && !image.content_type.in?(%w[image/jpeg image/png image/webp])
    end
  end
  validates :enrichment_state, inclusion: { in: %w[pending candidates matched no_match failed] }
  scope :visible, -> { where(hidden: false) }
  scope :showing, -> { visible.where(id: Performance.upcoming.select(:film_id)).order(performances_count: :desc, name: :asc) }

  def to_param
    public_id
  end

  def suffix
    [ name, year ].compact.join(" ").parameterize
  end

  def self.resolve_title!(name)
    normalized = FilmAlias.normalize(name)
    transaction do
      existing = FilmAlias.find_by(normalized_name: normalized)
      return existing.film if existing
      film = create!(name: name)
      film.film_aliases.create!(name: name)
      film
    end
  rescue ActiveRecord::RecordNotUnique
    FilmAlias.find_by!(normalized_name: normalized).film
  end

  def merge_into!(target)
    raise ArgumentError, "Cannot merge a film into itself" if target == self
    transaction do
      performances.each do |performance|
        duplicate = target.performances.find_by(cinema_id: performance.cinema_id, dimension: performance.dimension, starting_at: performance.starting_at)
        duplicate ? performance.destroy! : performance.update!(film: target)
      end
      film_aliases.update_all(film_id: target.id)
      target.film_aliases.create!(name: name) unless target.film_aliases.exists?(normalized_name: FilmAlias.normalize(name))
      external_identifiers.each do |identifier|
        identifier.update!(identifiable: target) unless target.external_identifiers.exists?(source: identifier.source)
      end
      reload.destroy!
      self.class.reset_counters(target.id, :performances)
    end
  end
end
