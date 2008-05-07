class RestEasy
  module Format
    class Xml < Hash
      attr_accessor :elements, :rootname
      def initialize(elements=[], rootname=nil)
        @elements = elements
        @rootname = rootname
      end
      
      def to_xml
        XmlEasy.xml_out_easy(self)
      end
    end
  end
end