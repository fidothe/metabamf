require 'metabamf/structure/definition'

module Metabamf
  module Boxes
    Ftyp = Structure::Definition.new('ftyp') do |d|
      d.attr :major_brand, required: true
      d.attr :minor_version, required: true
      d.attr :compatible_brands, required: true

      d.deserializer = ->(box, attrs) {
        header_size = box.pos - box.start_pos
        major_brand = box.read_ascii_bytes(4)
        minor_version = box.read_uint32
        remaining_bytes = attrs[:size] - (header_size + 8)
        compatible_brands = box.read_ascii_bytes(remaining_bytes).chars.each_slice(4).map(&:join)
        attrs.merge({
          major_brand: major_brand, minor_version: minor_version,
          compatible_brands: compatible_brands
        })
      }
    end
  end
end
