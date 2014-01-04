class Film < ActiveRecord::Base
  validates :name, presence: true
end
