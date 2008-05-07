require File.dirname(__FILE__) + '/helper'

class FormatsTest < Test::Unit::TestCase
  context 'XML format' do
    setup { @xml1 = File.new(File.join(File.dirname(__FILE__), 'fixtures', 'test1.xml')).read.gsub "\n", '' }

    should 'parse a document' do
      hash1 = RestEasy::Format::Xml.parse @xml1
      hash2 = XmlEasy.xml_in_easy @xml1
      assert_equal hash1, hash2
    end
    
    should 'reprocess a document' do
      hash = XmlEasy.xml_in_easy @xml1
      out = hash.to_xml.gsub "\n", ''
      assert_equal out, @xml1
    end
  end
end