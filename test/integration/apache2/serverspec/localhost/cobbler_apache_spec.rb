require 'spec_helper'
require 'uri'
require 'faraday'

describe "cobbler server" do
  it "is listening on port 80" do
    expect(port(80)).to be_listening
  end

  it "is showing a page with the text 'Cobbler'" do
    connection = Faraday.new URI.parse('http://localhost')
    page = connection.get('/cobbler_api').body
    expect(page).to match /Cobbler/
  end

  it "is showing a page with the text 'Cobbler'" do
    connection = Faraday.new URI.parse('http://localhost')
    page = connection.get('/cobbler_webui_content').body
    expect(page).to match /Cobbler/
  end
end


