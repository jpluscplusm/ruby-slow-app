require File.expand_path '../spec_helper.rb', __FILE__

require "net/http"
require "uri"

describe 'slow app' do
  describe '/slow' do
    it 'takes the specified amount of seconds to return a response' do
      beforeGet = Time.now
      get '/slow?delay=1'
      afterGet = Time.now
      expect(last_response).to be_ok
      expect(afterGet - beforeGet).to be >= 1
    end
  end
end
