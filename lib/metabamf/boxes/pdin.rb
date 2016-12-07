require 'metabamf/structure/definition'

module Metabamf
  module Boxes
    Pdin = Structure::Definition.new('pdin') do |d|
      d.full_box!
      d.attr :rate_and_delay_pairs, required: true

      d.deserializer = ->(io, start_offset, attrs) {
        offset = io.pos
        header_size = offset - start_offset
        remaining_bytes = attrs[:size] - header_size
        pairs = remaining_bytes / 8
        rate_and_delay_pairs = pairs.times.map { io.read(8).unpack("NN") }
        attrs.merge({
          rate_and_delay_pairs: rate_and_delay_pairs
        })
      }
    end
  end
end
