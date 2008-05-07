$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

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
require File.join('resteasy', 'format', 'json')
require File.join('resteasy', 'format', 'xml')

# require 'resteasy'
# a = RestEasy.new
# a.get('http://www.360voice.com/api/blog-getentries.asp?tag=fajitaman')

class RestEasy
  VERSION = '0.1.0'
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

    # Process the body based on format
    unless body.nil?
      if body.is_a?(RestEasy::Format::Xml)
        request.body = XmlEasy.xml_out_easy(body)
      elsif body.is_a?(RestEasy::Format::Json)
        request.body = body.to_json
      else
        request.body = body
      end
    end

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    result = http.start { |h| h.request(request) }
    
    case result
    when Net::HTTPSuccess

      # Handle the response
      case result.content_type
      when 'text/xml'
        return XmlEasy.xml_in_easy(result.body)
      when 'text/json'
        hash = JSON.parse(result.body)
        json = RestEasy::Format::Json.new
        return json.merge(hash)
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