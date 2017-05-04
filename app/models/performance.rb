# frozen_string_literal: true
class Performance < ActiveRecord::Base
  belongs_to :cinema
  belongs_to :film, counter_cache: true

  validates :cinema_id, :film_id, :dimension, :starting_at, presence: true

  before_save :dimension_downcase!
  before_save :variant_downcase!

  scope :ordered, -> { order(starting_at: :asc) }
  scope :past, -> { before(Time.current) }

  def self.after(time)
    where(arel_table[:starting_at].gt(time))
  end

  def self.before(time)
    where(arel_table[:starting_at].lt(time))
  end

  def self.between(start_on, end_on)
    after(beginning_of_day_or_current(start_on))
      .before(end_on.end_of_day)
      .ordered
  end

  def self.on(date)
    between(date, date)
  end

  def update_variant!(variant)
    update_attributes(variant: variant)
  end

  private

  def self.beginning_of_day_or_current(date)
    date.to_date == Time.current.to_date ? Time.current : date.beginning_of_day
  end
  private_class_method :beginning_of_day_or_current

  def dimension_downcase!
    dimension.downcase!
  end

  def variant_downcase!
    variant.downcase!
  end
end
