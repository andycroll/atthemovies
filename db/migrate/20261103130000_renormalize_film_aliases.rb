class RenormalizeFilmAliases < ActiveRecord::Migration[8.1]
  def up
    FilmAlias.transaction do
      groups = FilmAlias.order(:id).group_by { FilmAlias.normalize(_1.name) }
      targets = merge_targets(groups.values.map { |group| group.map(&:film_id).uniq })
      FilmAlias.update_all("normalized_name = 'pending-' || id")

      groups.each do |normalized, (kept, *duplicates)|
        kept.update_columns(normalized_name: normalized, film_id: targets.fetch(kept.film_id, kept.film_id))
        FilmAlias.where(id: duplicates.map(&:id)).delete_all
      end

      targets.each do |film_id, target_id|
        Film.find(film_id).merge_into!(Film.find(target_id)) unless film_id == target_id
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  # Films sharing a normalized name, each mapped to the film they merge into
  def merge_targets(film_groups)
    components = []
    film_groups.select { _1.size > 1 }.each do |ids|
      joined = components.select { (_1 & ids).any? }
      components = components - joined + [ (joined.flatten + ids).uniq ]
    end

    matched = ExternalIdentifier.where(identifiable_type: "Film", source: "tmdb_movie").pluck(:identifiable_id).to_set
    components.flat_map do |ids|
      target = Film.where(id: ids).max_by { [ matched.include?(_1.id) ? 1 : 0, _1.performances_count, -_1.id ] }
      ids.map { [ _1, target.id ] }
    end.to_h
  end
end
