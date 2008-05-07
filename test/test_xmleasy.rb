require File.dirname(__FILE__) + '/helper'

class XmlEasyTest < Test::Unit::TestCase
  context 'XmlEasy' do
    setup do
      @xml1 = File.new(File.join(File.dirname(__FILE__), 'fixtures', 'test1.xml')).read.gsub "\n", ''
      @xml2 = File.new(File.join(File.dirname(__FILE__), 'fixtures', 'test2.xml')).read.gsub "\n", ''
    end

    context 'xml deserialization' do        
      should 'read proper special elements' do
        @x = XmlEasy.xml_in_easy(@xml1)
        assert_equal @x.elements, ['Body']
      end
      
      should 'not add the contentkey to the special elements' do
        @x = XmlEasy.xml_in_easy(@xml2)
        assert !@x.elements.include?('content')
      end
      
      should 'return proper rootname' do
        @x = XmlEasy.xml_in_easy(@xml1)
        assert_equal @x.rootname, 'Message'
      end
      
      should 'return proper elements' do
        @x = XmlEasy.xml_in_easy(@xml1)
        assert_equal @x, {"Body"=>"This is a test", "Id"=>"480ca9fb-53ce-45b2-bcc8-afa82e3e73e"}
      end
    end
    
    context 'xml serialization' do
      should 'convert back to proper xml' do
        @hash = RestEasy::Format::Xml.new.merge({"Body"=>"This is a test", "Id"=>"480ca9fb-53ce-45b2-bcc8-afa82e3e73e"})
        @hash.elements = ['Body']
        @hash.rootname = 'Message'

        @out = XmlEasy.xml_out_easy(@hash).gsub "\n", ''
        assert_equal @out, @xml1
      end
      
      should 'handle content keys are element values' do
        @hash = RestEasy::Format::Xml.new.merge({"Message"=>[{"Id"=>"1", "content"=>"test", "Yes"=>"no"}, {"Id"=>"2", "Yes"=>"yes"}, {"Id"=>"3", "content"=>"blah"}]})
        @hash.rootname = 'Messages'

        @out = XmlEasy.xml_out_easy(@hash).gsub "\n", ''
        assert_equal @out, @xml2
      end
    end
  end
end