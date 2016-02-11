class Performance < ActiveRecord::Base
  belongs_to :cinema
  belongs_to :film, counter_cache: true

  validates :cinema_id, :film_id, :dimension, :starting_at, presence: true

  before_save :dimension_downcase!
  before_save :variant_downcase!

  scope :ordered, -> { order(starting_at: :asc) }
  scope :past, -> { where(Performance.arel_table[:starting_at].lt(Time.current)) }

  def self.on(date)
    if date.to_date == Time.current.to_date
      where(Performance.arel_table[:starting_at].gt(Time.current))
        .where(Performance.arel_table[:starting_at].lt(date.end_of_day))
        .ordered
    else
      where(Performance.arel_table[:starting_at].gt(date.beginning_of_day))
        .where(Performance.arel_table[:starting_at].lt(date.end_of_day))
        .ordered
    end
  end

  def update_variant!(variant)
    update_attributes(variant: variant)
  end

  private

  def dimension_downcase!
    dimension.downcase!
  end

  def variant_downcase!
    variant.downcase!
  end
end
