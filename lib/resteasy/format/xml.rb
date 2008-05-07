class RestEasy
  module Format
    class Xml < Hash
      attr_accessor :elements, :rootname

      # Creates a new instance of the RestEasy::Format::Xml object with the given elements and rootname
      #   +elements+ (optional) is a list of attributes that should be reprocessed as element strings
      #     instead of attributes
      #   +rootname+ (optional) is the name of the root element for reprocessing later
      def initialize(elements=[], rootname=nil)
        @elements = elements
        @rootname = rootname
      end
      
      def self.parse(xml)
        XmlEasy.xml_in_easy(xml)
      end

      # Convert the current RestEasy::Format::Xml object to XML, preserving
      # the original root name and attribute/element string composition
      def to_xml
        XmlEasy.xml_out_easy(self)
      end
    end
  end
end