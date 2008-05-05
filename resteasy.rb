require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'

begin
  require 'xml_simple'
rescue LoadError
  require 'rubygems'
  require 'active_support'
  begin
  require 'xml_simple'
  rescue LoadError
    require 'xmlsimple'
  end
end

require File.join('resteasy', 'xmleasy')
require File.join('resteasy', 'format', 'xml')

# require 'resteasy'
# a = RestEasy.new
# a.get('http://www.360voice.com/api/blog-getentries.asp?tag=fajitaman')

class RestEasy
  attr_accessor :headers, :username, :password
  
  ['copy', 'delete', 'get', 'head', 'lock', 'mkcol', 'move', 'options', 'post', 'propfind', 'proppatch', 'put', 'trace', 'unlock'].each do |verb|
    self.class_eval <<-EOS, __FILE__, __LINE__
      def #{verb}(url, body = nil)
        perform(:#{verb.capitalize}, url, body)
      end
    EOS
  end
  
  private
  def perform(verb, url, body = nil, limit = 2) #:nodoc
    uri = URI.parse(url)

    request = Net::HTTP.const_get(verb).new(uri.request_uri)
    request.initialize_http_header(@headers)
    request.basic_auth(@username, @password) if username
    request.body = body unless body.nil?

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    result = http.start { |h| h.request(request) }
    
    case result
    when Net::HTTPSuccess

      # Handle the response
      case result.content_type
      when 'text/xml'
        return XmlSimple.xml_in_string(result.body, 'keeproot' => false)
      when 'text/json'
        return JSON.parse(result.body)
      else
        return result.body
      end

    when Net::HTTPRedirection
      # Process a redirection
      return perform(verb, response['location'], body, limit - 1) if limit > 1
      # TODO raise error if too many?
    else
      # Print an exception
      puts "ERROR #{result.coce}: #{result.message}\n\t#{result.body}"
      result.error!
    end
  end
end