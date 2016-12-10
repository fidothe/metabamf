require 'metabamf/structure/definition'

module Metabamf
  module Boxes
    Moov = Structure::Definition.new('moov') do |d|
      d.contains :mvhd, required: true
      d.contains_multiple :traks, boxtype: 'trak'
      d.contains :mvex
      d.contains :udta

      d.deserializer = ->(box, attrs) {
        children = box.parse_children
        traks = children.fetch_group('trak')
        attrs.merge({
          mvhd: children.fetch('mvhd'), traks: traks, mvex: children.fetch('mvex'),
          udta: children.fetch('udta')
        }.reject { |k,v| v.nil? })
      }
    end
  end
end
