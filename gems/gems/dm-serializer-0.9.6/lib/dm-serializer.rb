require Pathname('rexml/document')

begin
  require 'faster_csv'
rescue LoadError
  nil
end

begin
  require Pathname('json/ext')
rescue LoadError
  require Pathname('json/pure')
end

module DataMapper
  module Serialize

    # Serialize a Resource to JavaScript Object Notation (JSON; RFC 4627)
    #
    # @return <String> a JSON representation of the Resource
    def to_json(options = {})
      result = '{ '
      fields = []

      # FIXME: this should go into bunch of protected methods shared with other serialization methods
      only_properties     = Array(options[:only])
      excluded_properties = Array(options[:exclude])
      exclude_read_only   = options[:without_read_only_attributes] || false

      propset = self.class.properties(repository.name).reject do |p|
        next if only_properties.include? p.name
        excluded_properties.include?(p.name) || !(only_properties.empty? || only_properties.include?(p.name))
      end

      fields += propset.map do |property|
        "#{property.name.to_json}: #{send(property.getter).to_json}"
      end

      if self.respond_to?(:serialize_properties)
        self.serialize_properties.each do |k,v|
          fields << "#{k.to_json}: #{v.to_json}"
        end
      end

      if self.class.respond_to?(:read_only_attributes) && exclude_read_only
        self.class.read_only_attributes.each do |property|
          fields << "#{property.to_json}: #{send(property).to_json}"
        end
      end

      # add methods
      (options[:methods] || []).each do |meth|
        if self.respond_to?(meth)
          fields << "#{meth.to_json}: #{send(meth).to_json}"
        end
      end

      result << fields.join(', ')
      result << ' }'
      result
    end

    # Serialize a Resource to comma-separated values (CSV).
    #
    # @return <String> a CSV representation of the Resource
    def to_csv(writer = '')
      FasterCSV.generate(writer) do |csv|
        row = []
        self.class.properties(repository.name).each do |property|
         row << send(property.name).to_s
        end
        csv << row
      end
    end

    # Serialize a Resource to XML
    #
    # @return <REXML::Document> an XML representation of this Resource
    def to_xml(opts = {})

      to_xml_document(opts).to_s
    end

    # Serialize a Resource to YAML
    #
    # @return <YAML> a YAML representation of this Resource
    def to_yaml(opts = {})
      YAML::quick_emit(object_id,opts) do |out|
        out.map(nil,to_yaml_style) do |map|
          self.class.properties(repository.name).each do |property|
            value = send(property.name.to_sym)
            map.add(property.name, value.is_a?(Class) ? value.to_s : value)
          end
          (instance_variable_get("@yaml_addes") || []).each do |k,v|
            map.add(k.to_s,v)
          end
        end
      end
    end

    protected

    # Return the name of this Resource - to be used as the root element name.
    # This can be overloaded.
    #
    # @return <String> name of this Resource
    def xml_element_name
      Extlib::Inflection.underscore(self.class.name)
    end

    # Return a REXML::Document representing this Resource
    #
    # @return <REXML::Document> an XML representation of this Resource
    def to_xml_document(opts={}, doc=nil)
      doc ||= REXML::Document.new
      root = doc.add_element(xml_element_name)

      #TODO old code base was converting single quote to double quote on attribs

      self.class.properties(repository.name).each do |property|
          value = send(property.name)
          node = root.add_element(property.name.to_s)
          unless property.type == String
            node.attributes["type"] = property.type.to_s.downcase
          end
          node << REXML::Text.new(value.to_s) unless value.nil?
      end
      doc
    end

  end # module Serialize

  module Resource
    include Serialize
  end # module Resource

  class Collection
    def to_yaml(opts = {})
      to_a.to_yaml(opts)
    end

    def to_json(opts = {})
      "[" << map {|e| e.to_json(opts)}.join(",") << "]"
    end

    def to_xml(opts = {})
      to_xml_document(opts).to_s
    end

    def to_csv
      result = ""
      each do |item|
        result << item.to_csv + "\n"
      end
      result
    end

    protected
    def xml_element_name
      Extlib::Inflection.tableize(self.model.to_s)
    end

    def to_xml_document(opts={})
      doc = REXML::Document.new
      root = doc.add_element(xml_element_name)
      root.attributes["type"] = 'array'
      each do |item|
        item.send(:to_xml_document, opts, root)
      end
      doc
    end
  end

end # module DataMapper
