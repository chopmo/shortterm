require 'faraday'
require 'json'

class ApiClient
  def self.get_epics
    response = Faraday.get("https://api.app.shortcut.com/api/v3/epics") do |req|
      req.headers["Shortcut-Token"] = shortcut_api_token
      req.headers["Content-Type"] = "application/json"
      req.body = JSON.generate({ includes_description: false })
    end
    JSON.parse(response.body, object_class: OpenStruct)
  end

  def self.get_stories(epic_id)
    response = Faraday.get("https://api.app.shortcut.com/api/v3/epics/#{epic_id}/stories") do |req|
      req.headers["Shortcut-Token"] = shortcut_api_token
      req.headers["Content-Type"] = "application/json"
      req.body = JSON.generate({ includes_description: false })
    end
    JSON.parse(response.body, object_class: OpenStruct)
  end

  def self.shortcut_api_token
    open(File.expand_path("~/.shortcut-api-token")).read
  rescue
    puts "Unable to find shortcut API token in ~/.shortcut-api-token"
    puts "Generate a token here: https://app.shortcut.com/gomore/settings/account/api-tokens"
    raise "No Shortcut token"
  end
end
