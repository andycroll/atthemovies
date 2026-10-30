# Read hand-written fixtures from disk. They follow the shape in
# api_shapes.rb; they are never recorded output from showcasecinemas.co.uk.
module FixturesHelper
  private

  def home_html
    read_fixture('website/home.html')
  end

  def page_data_index_json
    read_fixture('api/page-data-index.json')
  end

  def theaters_json
    read_fixture('api/theaters.json')
  end

  def schedule_json(theater_id)
    read_fixture("api/schedule-#{theater_id}.json")
  end

  def movies_json
    read_fixture('api/movies.json')
  end

  def read_fixture(filepath)
    File.read(File.expand_path("../../fixtures/#{filepath}", __FILE__))
  end
end
