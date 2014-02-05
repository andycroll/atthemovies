class Screening < ActiveRecord::Base
  belongs_to :cinema
  belongs_to :film, counter_cache: true

  validates :showing_at, :variant, presence: true

  def set_variant(variant)
    update_attributes(variant: variant, updated_at: Time.current)
  end
end
