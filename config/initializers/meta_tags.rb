# Search engines truncate long titles themselves; the default 70-character
# limit would cut long film and cinema names.
MetaTags.configure do |config|
  config.title_limit = nil
end
