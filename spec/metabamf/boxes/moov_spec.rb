require 'metabamf/boxes/moov'
require 'metabamf/parser/stream'
require 'metabamf/parser/box'

module Metabamf::Boxes
  RSpec.describe Moov do
    let(:fixture_dir) { Pathname.new(__dir__).join('../../fixtures/boxes') }
    let(:io) { fixture_dir.join('moov.mp4').open('rb') }
    let(:definitions) { Hash[
      'moov' => subject
    ] }
    let(:stream) { Metabamf::Parser::Stream.new(io, definitions) }
    let(:parser) { Metabamf::Parser::Box.new(stream) }

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

      xit "may have a meta child" do
        expect(entity.meta.boxtype).to eq('meta')
      end

      it "has trak children" do
        expect(entity.traks.first.boxtype).to eq('trak')
      end

      xit "may have an mvex child" do
        expect(entity.mvex.boxtype).to eq('mvex')
      end

      it "may have a udta child" do
        expect(entity.udta.boxtype).to eq('udta')
      end
    end
  end
end
