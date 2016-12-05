require 'metabamf/structure/definition'

module Metabamf
  module Boxes
    Ftyp = Structure::Definition.new('ftyp') do |d|
      d.attr :major_brand, required: true
      d.attr :minor_version, required: true
      d.attr :compatible_brands, required: true

      d.deserializer = ->(io, start_offset, attrs) {
        offset = io.pos
        header_size = offset - start_offset
        major_brand = io.read(4)
        minor_version = io.read(4).unpack("N").first
        remaining_bytes = attrs[:size] - (header_size + 8)
        compatible_brands = io.read(remaining_bytes).chars.each_slice(4).map(&:join)
        attrs.merge({
          major_brand: major_brand, minor_version: minor_version,
          compatible_brands: compatible_brands
        })
      }
    end
  end
end
