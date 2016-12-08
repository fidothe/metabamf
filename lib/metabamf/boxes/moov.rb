require 'metabamf/structure/definition'

module Metabamf
  module Boxes
    Moov = Structure::Definition.new('moov') do |d|
      d.contains :mvhd, required: true
      d.contains_multiple :traks, boxtype: 'trak'
      d.contains :mvex
      d.contains :udta

      d.deserializer = ->(io, start_offset, attrs, parser) {
        offset = io.pos
        size = attrs[:size]
        end_offset = start_offset + size
        children = parser.parse_children(io, offset, end_offset)
        traks = children.select { |k, v| k == 'trak' }.map { |k, v| v }
        attrs.merge({
          mvhd: children['mvhd'], traks: traks, mvex: children['mvex'],
          udta: children['udta']
        }.compact)
      }
    end
  end
end
