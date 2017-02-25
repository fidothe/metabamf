require 'metabamf/entity/common'

module Metabamf
  class ExplicitBoxtypeRequired < StandardError
    def initialize(name)
      @name = name
    end

    def to_s
      "attribute #{@name} MUST have :boxtype specified explicitly"
    end
  end

  class BoxDefinition
    DEFAULT_DESERIALIZER = ->(box, attrs) { attrs }

    attr_reader :boxtype, :simple_attributes, :contained_single_boxes,
      :contained_multiple_boxes

    def initialize(boxtype)
      @full_box = false
      @boxtype = boxtype
      @simple_attributes = {
        boxtype: {required: true}, size: {required: true}
      }
      @contained_single_boxes = {}
      @contained_multiple_boxes = {}

      yield(self) if block_given?
    end

    def attr(name, opts = {})
      defaults = {required: false}
      simple_attributes[name] = defaults.merge(opts)
    end

    def contains(name, opts = {})
      defaults = {required: false, boxtype: name.to_s}
      contained_single_boxes[name] = defaults.merge(opts)
    end

    def contains_multiple(name, opts = {})
      raise ExplicitBoxtypeRequired.new(name) unless opts.has_key?(:boxtype)
      defaults = {required: false}
      contained_multiple_boxes[name] = defaults.merge(opts)
    end

    def full_box!
      @full_box = true
      attr(:version, required: true)
      attr(:flags, required: true)
    end

    def full_box?
      @full_box
    end

    def entity
      @entity ||= Entity.generate({
        optional: optional_attrs,
        required: required_attrs,
        multiple_box: multiple_box_attrs,
        query: query_method_attrs
      })
    end

    def deserializer
      ->(box) {
        deserializer = (@deserializer || DEFAULT_DESERIALIZER)
        attrs = {boxtype: box.boxtype, size: box.size}
        attrs = attrs.merge(read_full_box_fields(box)) if full_box?
        entity.new(deserializer.call(box, attrs))
      }
    end

    def deserializer=(deserializer_proc)
      @deserializer = deserializer_proc
    end

    private

    def read_full_box_fields(box)
      version = box.read_uint8
      flags = box.read_uint8 << 16 | box.read_uint16
      {version: version, flags: flags}
    end

    def gathered(*omit)
      [
        :simple_attributes, :contained_single_boxes, :contained_multiple_boxes
      ].reject { |method|
        omit.include?(method)
      }.inject({}) { |gathered, method|
        gathered.merge(send(method))
      }
    end

    def optional_attrs
      gathered.reject { |name, opts|
        opts[:required]
      }.map { |name, opts| name }
    end

    def required_attrs
      gathered.select { |name, opts|
        opts[:required]
      }.map { |name, opts| name }
    end

    def attr_reader_attrs
      gathered.map { |name, opts| name }
    end

    def query_method_attrs
      gathered(:contained_multiple_boxes).reject { |name, opts|
        opts[:required]
      }.map { |name, opts| name }
    end

    def multiple_box_attrs
      contained_multiple_boxes.map { |name, opts|
        name
      }
    end
  end
end
