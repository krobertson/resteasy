class XmlEasy < XmlSimple
  attr_accessor :elements
  
  def self.xml_in_easy(string)
    self.new.xml_in_easy(string)
  end
  
  def self.xml_out_easy(hash)
    self.new.xml_out_easy(hash)
  end
  
  def initialize
    @elements = []
  end
  
  def xml_in_easy(string)
    options = { 'keeproot' => true, 'forcearray' => false}
    hash = xml_in_string(string, options)
    easy = RestEasy::Format::Xml.new(elements, hash.keys.first)
    easy = easy.merge(hash[easy.rootname])
  end
  
  def xml_out_easy(hash)
    if hash.is_a?(RestEasy::Format::Xml)
      @elements = hash.elements
      hash = { hash.rootname => {}.merge(hash) }
    end
    xml_out(hash, { 'keeproot' => true })
  end
  
  def merge(hash, key, value)
    @elements << key unless value.is_a?(Hash) or value.is_a?(Array)
    super
  end

  def value_to_xml(ref, name, indent)
    named = !name.nil? && name != ''
    nl    = @options.has_key?('noindent') ? '' : "\n"

    if !scalar(ref)
      if @ancestors.member?(ref)
        raise ArgumentError, "Circular data structures not supported!"
      end
      @ancestors << ref
    else
      if named
        return [indent, '<', name, '>', @options['noescape'] ? ref.to_s : escape_value(ref.to_s), '</', name, '>', nl].join('')
      else
        return ref.to_s + nl
      end
    end

    # Unfold hash to array if possible.
    if ref.instance_of?(Hash) && !ref.empty? && !@options['keyattr'].empty? && indent != ''
      ref = hash_to_array(name, ref)
    end

    result = []
    if ref.instance_of?(Hash)
      # Reintermediate grouped values if applicable.
      if @options.has_key?('grouptags')
        ref.each { |key, value|
          if @options['grouptags'].has_key?(key)
            ref[key] = { @options['grouptags'][key] => value }
          end
        }
      end
      
      nested = []
      text_content = nil
      if named
        result << indent << '<' << name
      end

      if !ref.empty?
        ref.each { |key, value|
          next if !key.nil? && key[0, 1] == '-'
          if value.nil?
            unless @options.has_key?('suppressempty') && @options['suppressempty'].nil?
              raise ArgumentError, "Use of uninitialized value!"
            end
            value = {}
          end

          if !scalar(value) || @options['noattr'] || @elements.include?(key)
            nested << value_to_xml(value, key, indent + @options['indent'])
          else
            value = value.to_s
            value = escape_value(value) unless @options['noescape']
            if key == @options['contentkey']
              text_content = value
            else
              result << ' ' << key << '="' << value << '"'
            end
          end
        }
      else
        text_content = ''
      end

      if !nested.empty? || !text_content.nil?
        if named
          result << '>'
          if !text_content.nil?
            result << text_content
            nested[0].sub!(/^\s+/, '') if !nested.empty?
          else
            result << nl
          end
          if !nested.empty?
            result << nested << indent
          end
          result << '</' << name << '>' << nl
        else
          result << nested
        end
      else
        result << ' />' << nl
      end
    elsif ref.instance_of?(Array)
      ref.each { |value|
        if scalar(value)
          result << indent << '<' << name << '>'
          result << (@options['noescape'] ? value.to_s : escape_value(value.to_s))
          result << '</' << name << '>' << nl
        elsif value.instance_of?(Hash)
          result << value_to_xml(value, name, indent)
        else
          result << indent << '<' << name << '>' << nl
          result << value_to_xml(value, @options['anonymoustag'], indent + @options['indent'])
          result << indent << '</' << name << '>' << nl
        end
      }
    else
      # Probably, this is obsolete.
      raise ArgumentError, "Can't encode a value of type: #{ref.type}."
    end
    @ancestors.pop if !scalar(ref)
    result.join('')
  end

end