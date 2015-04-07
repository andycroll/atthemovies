class Film < ActiveRecord::Base
  has_many :screenings
  has_many :cinemas, -> { distinct }, through: :screenings

  validates :name, presence: true

  before_update :add_old_name_to_alternate_names, if: :name_change
  before_update :information_not_added, if: :tmdb_identifier_change
  after_commit :fetch_backdrop, if: 'previous_changes[:backdrop_source_uri]'
  after_commit :fetch_external_ids, if: 'previous_changes[:name]'
  after_commit :fetch_poster, if: 'previous_changes[:poster_source_uri]'

  acts_as_url :name, sync_url: true

  def self.alternately_named(name)
    where('alternate_names @> ?', "{#{name.gsub(',', '')}}")
  end

  def self.find_named(name)
    find_by(url: name.to_url) || alternately_named(name).first
  end

  def self.find_or_create_by_name(name)
    find_named(name) || create(name: name)
  end

  def self.no_information
    where(information_added: false)
  end

  def self.no_tmdb_details
    no_tmdb_id.where("tmdb_possibles = '{}'")
  end

  def self.no_tmdb_id
    where(tmdb_identifier: nil)
  end

  scope :similar_to, ->(name) { advanced_search(name: name.gsub(/[^0-9A-Za-z ]/, '').gsub(/\s+/, '|')) }

  def self.whats_on
    where(Film.arel_table[:screenings_count].gt(0))
      .order(screenings_count: :desc)
  end

  def add_alternate_name(name)
    update_attributes(alternate_names: self.alternate_names + [name])
  end

  def update_external_information_from(tmdb_movie)
    update_attributes(name:                tmdb_movie.title,
                      imdb_identifier:     tmdb_movie.imdb_number.to_s,
                      overview:            tmdb_movie.overview,
                      runtime:             tmdb_movie.runtime,
                      tagline:             tmdb_movie.tagline,
                      year:                tmdb_movie.year,
                      poster_source_uri:   tmdb_movie.poster.uri,
                      backdrop_source_uri: tmdb_movie.backdrop.uri,
                      information_added:   true)
  end

  def needs_external_information?
    tmdb_identifier? && !information_added?
  end

  def update_possibles(array)
    update_attributes(tmdb_possibles: array)
  end

  private

  def add_old_name_to_alternate_names
    self.alternate_names = alternate_names + [name_was]
  end

  def information_not_added
    self.information_added = false
    fetch_external_information if tmdb_identifier.present?
    true
  end

  def fetch_external_ids
    Films::FetchExternalIds.perform_later(self)
  end

  def fetch_external_information
    Films::FetchExternalInformation.perform_later(self)
  end

  def fetch_backdrop
    Films::FetchBackdrop.perform_later(self)
  end

  def fetch_poster
    Films::FetchPoster.perform_later(self)
  end
end
