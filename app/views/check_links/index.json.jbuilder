json.array!(@check_links) do |check_link|
  json.extract! check_link, :id, :checked_url, :errors_found
  json.url check_link_url(check_link, format: :json)
end
