require 'stringio'
require 'metabamf/structure/definition'
require 'metabamf/parser/stream'
require 'metabamf/parser/box'

module Metabamf::Parser
  RSpec.describe Stream do
    let(:deserializer) { double }
    let(:definition) {
      instance_double(Metabamf::Structure::Definition, {
        deserializer: deserializer
      })
    }
    let(:definitions) { {'ftyp' => definition} }
    let(:io) { StringIO.new('') }

    subject { Stream.new(io, definitions) }

    it "can look up a definition instance" do
      expect(subject.definition('ftyp')).to be(definition)
    end

    it "can return a deserializer from a definition" do
      expect(subject.deserializer('ftyp')).to be(deserializer)
    end

    context "working with the IO" do
      let(:io) { StringIO.new('FOUR') }

      it "can delegates #read to its IO" do
        expect(subject.read(4)).to eq('FOUR')
      end

      it "can seek to a specified point in the IO" do
        subject.seek_to(2)

        expect(io.pos).to eq(2)
      end

      it "can report the position of the IO" do
        subject.seek_to(2)

        expect(subject.pos).to eq(2)
      end

      it "can seek to the end of the IO" do
        subject.seek_to_end

        expect(io.pos).to eq(4)
      end
    end

    context "parsing out boxes" do
      let(:fixture_dir) { Pathname.new(__dir__).join('../../fixtures') }
      let(:io) { fixture_dir.join('sequence.mp4').open('rb') }
      let(:definitions) { Hash[
        'fltc' => Metabamf::Structure::Definition.new('fltc') do |d|
          d.attr :blah, required: true
          d.deserializer = ->(box, attrs) {
            attrs.merge({blah: box.read_ascii_bytes(4)})
          }
        end,
        'aflc' => Metabamf::Structure::Definition.new('aflc') do |d|
          d.attr :meh, required: true
          d.deserializer = ->(box, attrs) {
            attrs.merge({meh: box.read_ascii_bytes(3)})
          }
        end,
      ] }

      it "can parse a single box" do
        entity = subject.parse_next_box
        expect(entity.boxtype).to eq('fltc')
      end

      it "can parse a bounded sequence of boxes" do
        entity_set = subject.parse_boxes_until(23)
        expect(entity_set.size).to eq(2)
        expect(entity_set.first.blah).to eq('blah')
        expect(entity_set.last.meh).to eq('meh')
      end

      it "can parse an unbounded sequence of boxes" do
        entity_set = subject.parse_boxes
        expect(entity_set.size).to eq(3)
        expect(entity_set[0].blah).to eq('blah')
        expect(entity_set[1].meh).to eq('meh')
        expect(entity_set[2].meh).to eq('meh')
      end

      context "parsing a complete file" do
        it "takes an IO and definitions and returns a Metabamf::File" do
          file = subject.parse_stream!
          expect(file).not_to have_pdin
          expect(file.each.map { |en| en.boxtype }).to eq(['fltc', 'aflc', 'aflc'])
        end

        it "offers a convenience class method that takes io and definitinos" do
          file = Stream.parse_stream!(io, definitions)
          expect(file).not_to have_pdin
          expect(file.each.map { |en| en.boxtype }).to eq(['fltc', 'aflc', 'aflc'])
        end
      end
    end
  end
end
