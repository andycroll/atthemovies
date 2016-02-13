class Performance < ActiveRecord::Base
  belongs_to :cinema
  belongs_to :film, counter_cache: true

  validates :cinema_id, :film_id, :dimension, :starting_at, presence: true

  before_save :dimension_downcase!
  before_save :variant_downcase!

  scope :ordered, -> { order(starting_at: :asc) }
  scope :past, -> { where(arel_table[:starting_at].lt(Time.current)) }

  def self.after(time)
    where(arel_table[:starting_at].gt(time))
  end

  def self.before(time)
    where(arel_table[:starting_at].lt(time))
  end

  def self.on(date)
    start = if date.to_date == Time.current.to_date
              Time.current
            else
              date.beginning_of_day
            end

    after(start).before(date.end_of_day).ordered
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
