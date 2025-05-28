module Idra
    class Search
      def self.call(api_url, payload)
        uri = URI(api_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
  
        request = Net::HTTP::Post.new(uri)
        request["Content-Type"] = "application/json"
        request.body = payload.to_json
  
        http.request(request)
      end
    end
  end
  