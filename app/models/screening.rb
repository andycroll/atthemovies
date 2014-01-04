class Screening < ActiveRecord::Base
  belongs_to :cinema
  belongs_to :film

  validates :showing_at, :variant, presence: true
end
