# frozen_string_literal: true
class FilmNameComparison
  def initialize(name)
    @name = name.to_s
  end

  def code
    @name.downcase.gsub(/[^a-z0-9]/, '').chars.sort.join
  end
end
