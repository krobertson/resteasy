$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'
require 'rubygems'

begin
  require 'xml_simple'
rescue LoadError
  require 'active_support'
  begin
    require 'xml_simple'
  rescue LoadError
    require 'xmlsimple'
  end
end

begin
  require 'json/pure'
rescue LoadError
  require 'json'
end

require File.join('resteasy', 'xmleasy')
require File.join('resteasy', 'format', 'json')
require File.join('resteasy', 'format', 'xml')

# == RestEasy
#
# Client library for easily interacting with any REST web service you
# can think of.
#
# For details on the usage, see the README.txt

class RestEasy
  VERSION = '0.1.0'
  attr_accessor :headers, :username, :password

  # Create a new instance of the RestEasy library
  #   +headers+ is a hash of header values that will be used on each request
  #
  # Examples:
  #   s = RestEasy.new
  #   s = RestEasy.new 'Auth-Token' => 'abcd1234'
  #
  # Returns RestEasy
  def initialize(headers = {})
    @headers = headers
  end

  # Sets the username/password to be used for basic authentication
  #   +username+ the username to use with the service
  #   +password+ the password to use with the service
  #     Password is optional and will be a blank string if not given
  def set_auth(username, password='')
    @username = username
    @password = password
  end
  
  # Clears any previously set authentication values
  def clear_auth
    @username = nil
    @password = nil
  end
  
  ['copy', 'delete', 'get', 'head', 'lock', 'mkcol', 'move', 'options', 'post', 'propfind', 'proppatch', 'put', 'trace', 'unlock'].each do |verb|
    self.class_eval <<-EOS, __FILE__, __LINE__
      public
      def #{verb}(url, body = nil)
        perform(:#{verb.capitalize}, url, body)
      end
    EOS
  end
  
  private
  def perform(verb, url, body = nil, limit = 3) #:nodoc
    uri = URI.parse(url)

    # Get the request type that pertains to the verb and set it up
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

    # Issue the request
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    result = http.start { |h| h.request(request) }
    
    # Handle the response
    case result
    when Net::HTTPSuccess

      # Successful response, attempt to parse
      case result.content_type
      when 'text/xml'
        return XmlEasy.xml_in_easy(result.body)
      when 'text/json'
        return RestEasy::Format::Json.new.merge(JSON.parse(result.body))
      else
        return result.body
      end

    when Net::HTTPRedirection
      # Process a redirection
      return perform(verb, result['location'], body, limit - 1) if limit > 1
      raise RedirectLoopException
    else
      # Return the response object so they can handle the error
      return result
    end
  end

  class RedirectLoopException < Exception
  end
end