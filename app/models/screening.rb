class Screening < ActiveRecord::Base
  belongs_to :cinema
  belongs_to :film, counter_cache: true

  validates :cinema_id, :film_id, :dimension, :showing_at, presence: true

  before_save :dimension_downcase!
  before_save :variant_downcase!

  scope :ordered, -> { order(showing_at: :asc) }
  scope :past,    -> { where(Screening.arel_table[:showing_at].lt(Time.current)) }

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
