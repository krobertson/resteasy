require File.dirname(__FILE__) + '/helper'

class RestEasyTest < Test::Unit::TestCase
  context 'RestEasy' do
    setup do
      @service = RestEasy.new
      @xml     = File.new(File.join(File.dirname(__FILE__), 'fixtures', 'test1.xml')).read.gsub "\n", ''
      @json    = File.new(File.join(File.dirname(__FILE__), 'fixtures', 'json1.txt')).read
    end

    context 'perform GET operation' do
      should 'return XML response' do
        response = Net::HTTPOK.new('get', 200, 'found')
        response.content_type = 'text/xml'
        response.expects(:body).returns(@xml)

        Net::HTTP.any_instance.expects(:start).returns(response)
        hash = @service.get('http://localhost/some/url')

        assert hash.is_a?(RestEasy::Format::Xml)
        assert_equal hash, {"Body"=>"This is a test", "Id"=>"480ca9fb-53ce-45b2-bcc8-afa82e3e73e"}
      end

      should 'return with JSON response' do
        response = Net::HTTPOK.new('get', 200, 'found')
        response.content_type = 'text/json'
        response.expects(:body).returns(@json)

        Net::HTTP.any_instance.expects(:start).returns(response)
        hash = @service.get('http://localhost/some/url')

        assert hash.is_a?(RestEasy::Format::Json)
        assert_equal hash, {"Body"=>"This is a test", "Id"=>"480ca9fb-53ce-45b2-bcc8-afa82e3e73e"}
      end

      should 'return plain text' do
        response = Net::HTTPOK.new('get', 200, 'found')
        response.content_type = 'text/plain'
        response.expects(:body).returns(@json)

        Net::HTTP.any_instance.expects(:start).returns(response)
        hash = @service.get('http://localhost/some/url')

        assert hash.is_a?(String)
        assert_equal hash, '{"Body": "This is a test", "Id": "480ca9fb-53ce-45b2-bcc8-afa82e3e73e"}'
      end
    end

    context 'perform POST/PUT responses' do
      should 'handle XML body' do
        hash = RestEasy::Format::Xml.new.merge({"Body"=>"This is a test", "Id"=>"480ca9fb-53ce-45b2-bcc8-afa82e3e73e"})
        hash.rootname = 'Message'

        response = Net::HTTPOK.new('post', 200, 'found')
        response.content_type = 'text/xml'
        response.expects(:body).returns(@xml)

        Net::HTTP.any_instance.expects(:start).returns(response)
        rhash = @service.post('http://localhost/some/url', hash)

        assert_equal hash, rhash
      end

      should 'handle JSON body' do
        hash = RestEasy::Format::Json.new.merge(JSON.parse(@json))

        response = Net::HTTPOK.new('post', 200, 'found')
        response.content_type = 'text/json'
        response.expects(:body).returns(@json)

        Net::HTTP.any_instance.expects(:start).returns(response)
        rhash = @service.post('http://localhost/some/url', hash)

        assert_equal hash, rhash
      end

      should 'handle plain text body' do
        response = Net::HTTPOK.new('post', 200, 'found')
        response.content_type = 'text/plain'
        response.expects(:body).returns(@json)

        Net::HTTP.any_instance.expects(:start).returns(response)
        rstring = @service.post('http://localhost/some/url', @json)

        assert_equal @json, rstring
      end
    end

    should 'process redirect responses' do
      response1 = Net::HTTPMovedPermanently.new('get', 301, 'moved')
      response1['location'] = 'http://localhost/some/other/url'

      response2 = Net::HTTPOK.new('post', 200, 'found')
      response2.content_type = 'text/xml'
      response2.expects(:body).returns(@xml)

      Net::HTTP.any_instance.expects(:start).times(2).returns(response1, response2)
      hash = @service.get('http://localhost/some/url')

      assert hash.is_a?(RestEasy::Format::Xml)
      assert_equal hash, {"Body"=>"This is a test", "Id"=>"480ca9fb-53ce-45b2-bcc8-afa82e3e73e"}
    end

    should 'process infinite redirect loops' do
      response = Net::HTTPMovedPermanently.new('get', 301, 'moved')
      response['location'] = 'http://localhost/some/other/url'

      Net::HTTP.any_instance.expects(:start).times(RestEasy.maximum_redirects).returns(response)
      
      assert_raise RestEasy::RedirectLoopException do
        hash = @service.get('http://localhost/some/url')
      end
    end

    should 'return response object in the event of an error response' do
      response = Net::HTTPNotFound.new('get', 404, 'not found')
      
      Net::HTTP.any_instance.expects(:start).returns(response)
      result = @service.get('http://localhost/some/url')

      assert result.is_a?(Net::HTTPNotFound)
      assert_equal response, result
    end
  end

  context 'Instance helper methods' do
    setup { @service = RestEasy.new }
    
    should 'set/return number of maximum redirects' do
      assert_equal 3, RestEasy.maximum_redirects

      RestEasy.maximum_redirects = 4
      assert_equal 4, RestEasy.maximum_redirects
    end
    
    should 'set authentication' do
      @service.set_auth('abcd', '1234')
      assert_equal 'abcd', @service.username
      assert_equal '1234', @service.password
    end
    
    should 'clear authentication' do
      @service.clear_auth
      assert_equal nil, @service.username
      assert_equal nil, @service.password
    end
  end
end