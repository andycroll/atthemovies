class FilmNameComparison
  def initialize(name)
    @name = name.to_s
  end

  def code
    @name.downcase.gsub(/[^a-z]/, '').chars.sort.join
  end
end
