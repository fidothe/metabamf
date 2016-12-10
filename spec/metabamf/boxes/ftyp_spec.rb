require 'metabamf/boxes/ftyp'
require 'metabamf/parser/stream'
require 'metabamf/parser/box'

module Metabamf::Boxes
  RSpec.describe Ftyp do
    let(:fixture_dir) { Pathname.new(__dir__).join('../../fixtures/boxes') }
    let(:io) { fixture_dir.join('ftyp.mp4').open('rb') }
    let(:definitions) {
      {'ftyp' => subject}
    }
    let(:stream) { Metabamf::Parser::Stream.new(io, definitions) }
    let(:parser) { Metabamf::Parser::Box.new(stream) }

    subject { Ftyp }

    it "has the correct boxtype" do
      expect(subject.boxtype).to eq('ftyp')
    end

    context "deserializing to an entity object" do
      let(:entity) { parser.deserialize }

      it "has the right boxtype" do
        expect(entity.boxtype).to eq('ftyp')
      end

      it "has the right size" do
        expect(entity.size).to eq(28)
      end

      it "has the right major brand" do
        expect(entity.major_brand).to eq('mp42')
      end

      it "has the right minor version" do
        expect(entity.minor_version).to eq(1)
      end

      it "has the right compatible brand list" do
        expect(entity.compatible_brands).to eq(%w{mp41 mp42 isom})
      end
    end
  end
end
