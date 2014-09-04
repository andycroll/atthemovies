class Screening < ActiveRecord::Base
  belongs_to :cinema
  belongs_to :film, counter_cache: true

  validates :showing_at, :variant, presence: true

  default_scope { order('showing_at ASC') }
  scope :past, -> { where('showing_at < ?', Time.current) }

  def set_variant(variant)
    update_attributes(variant: variant, updated_at: Time.current)
  end
end
