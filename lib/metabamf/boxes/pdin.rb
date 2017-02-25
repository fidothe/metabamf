require 'metabamf/box_definition'

module Metabamf
  module Boxes
    Pdin = BoxDefinition.new('pdin') do |d|
      d.full_box!
      d.attr :rate_and_delay_pairs, required: true

      d.deserializer = ->(box, attrs) {
        offset = box.pos
        header_size = offset - box.start_pos
        remaining_bytes = attrs[:size] - header_size
        pairs = remaining_bytes / 8
        rate_and_delay_pairs = pairs.times.map { [box.read_uint32, box.read_uint32] }
        attrs.merge({
          rate_and_delay_pairs: rate_and_delay_pairs
        })
      }
    end
  end
end
