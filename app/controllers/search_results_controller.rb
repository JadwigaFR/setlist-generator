require 'httparty'

class SearchResultsController < ApplicationController
  def search_concert
    setlist_id = search_params[:url].split('-').last.split('.').first
    json = get_request_for_url("#{ENV['SETLISTFM_URL']}setlist/#{setlist_id}")
    raise

  end

  private

  def get_request_for_url(url)
    headers = {
        'x-api-key': ENV['SETLISTFM_API_KEY'],
        'Accept': 'application/json'
    }
    response = HTTParty.get(url, headers: headers)
    JSON.parse(response.body)
  end

  def search_params
    params.permit(:url)
  end
end
