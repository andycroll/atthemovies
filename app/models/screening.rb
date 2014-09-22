class Screening < ActiveRecord::Base
  belongs_to :cinema
  belongs_to :film, counter_cache: true

  validates :cinema_id, :film_id, :dimension, :showing_at, presence: true

  before_save :dimension_downcase!
  before_save :variant_downcase!

  default_scope { order('showing_at ASC') }
  scope :past, -> { where('showing_at < ?', Time.current) }

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
