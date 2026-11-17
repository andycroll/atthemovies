xml.instruct!
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  [
    root_url, films_url, cinemas_url,
    *@cinemas.map { cinema_url(it, suffix: it.suffix) },
    *@films.map { film_url(it, suffix: it.suffix) }
  ].each { |location| xml.url { xml.loc location } }
end
