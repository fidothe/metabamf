require 'metabamf/boxes/moov'
require 'metabamf/parser/box'

module Metabamf::Boxes
  RSpec.describe Moov do
    let(:fixture_dir) { Pathname.new(__dir__).join('../../fixtures/boxes') }
    let(:io) { fixture_dir.join('moov.mp4').open('rb') }
    let(:deserializer_registry) {
      {'moov' => subject.deserializer}
    }
    let(:parser) { Metabamf::Parser::Box.new(io, deserializer_registry) }

    subject { Moov }

    it "has the correct boxtype" do
      expect(subject.boxtype).to eq('moov')
    end

    context "deserializing to an entity object" do
      let(:entity) { parser.deserialize }

      it "has the right boxtype" do
        expect(entity.boxtype).to eq('moov')
      end

      it "has the right size" do
        expect(entity.size).to eq(1565)
      end

      it "has a mvhd child" do
        expect(entity.mvhd.boxtype).to eq('mvhd')
      end

      it "has a meta child" do
        expect(entity.meta.boxtype).to eq('meta')
      end

      it "has trak children" do
        expect(entity.trak.first.boxtype).to eq('trak')
      end

      it "may have an mvex child" do
        expect(entity.mvex.boxtype).to eq('mvex')
      end

      it "may have a udta child" do
        expect(entity.mvex.boxtype).to eq('mvex')
      end
    end
  end
end
