class ApplicationController < ActionController::Base
  def get_request_for_url(url)
    headers = {
        'x-api-key': ENV['SETLISTFM_API_KEY'],
        'Accept': 'application/json'
    }
    response = HTTParty.get(url, headers: headers)
    JSON.parse(response.body)
  end
end
