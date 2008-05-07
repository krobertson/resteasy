class RestEasy
  module Format
    class Xml < Hash
      attr_accessor :elements, :rootname
      def initialize(elements=[], rootname=nil)
        @elements = elements
        @rootname = rootname
      end      
    end
  end
end