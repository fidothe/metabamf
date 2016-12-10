require 'metabamf/boxes/mvhd.rb'
require 'metabamf/parser/stream'
require 'metabamf/parser/box'

module Metabamf::Boxes
  RSpec.describe Mvhd do
    let(:fixture_dir) { Pathname.new(__dir__).join('../../fixtures/boxes') }
    let(:io) { fixture_dir.join('mvhd.mp4').open('rb') }
    let(:definitions) {
      {'mvhd' => subject}
    }
    let(:stream) { Metabamf::Parser::Stream.new(io, definitions) }
    let(:parser) { Metabamf::Parser::Box.new(stream) }

    subject { Mvhd }

    it "has the correct boxtype" do
      expect(subject.boxtype).to eq('mvhd')
    end

    context "deserializing to an entity object" do
      let(:entity) { parser.deserialize }

      it "has the right boxtype" do
        expect(entity.boxtype).to eq('mvhd')
      end

      it "has the right size" do
        expect(entity.size).to eq(108)
      end

      it "has the right version" do
        expect(entity.version).to eq(0)
      end

      it "has the right flags" do
        expect(entity.flags).to eq(0)
      end

      it "has the right creation_time" do
        expect(entity.creation_time).to eq(Time.parse('2016-12-03T22:34:59Z'))
      end

      it "has the right modification_time" do
        expect(entity.modification_time).to eq(Time.parse('2016-12-03T22:34:59Z'))
      end

      it "has the right timescale" do
        expect(entity.timescale).to eq(1000)
      end

      it "has the right duration" do
        expect(entity.duration).to eq(60000)
      end

      it "has the right duration in seconds" do
        expect(entity.duration_in_s).to eq(60.0)
      end

      it "has the right rate" do
        expect(entity.rate).to eq(1.0)
      end

      it "has the right volume" do
        expect(entity.volume).to eq(1.0)
      end

      it "has the right matrix" do
        expect(entity.matrix).to eq(Matrix[
          [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]
        ])
      end

      it "has the right next_track_id" do
        expect(entity.next_track_id).to eq(3)
      end

      context "a version 1 box" do
        let(:io) { fixture_dir.join('mvhd-v1.mp4').open('rb') }

        it "has the right boxtype" do
          expect(entity.boxtype).to eq('mvhd')
        end

        it "has the right size" do
          expect(entity.size).to eq(120)
        end

        it "has the right version" do
          expect(entity.version).to eq(1)
        end

        it "has the right flags" do
          expect(entity.flags).to eq(0)
        end

        it "has the right creation_time" do
          expect(entity.creation_time).to eq(Time.parse('2104-01-01T00:00:00Z'))
        end

        it "has the right modification_time" do
          expect(entity.modification_time).to eq(Time.parse('2104-01-01T00:00:00Z'))
        end

        it "has the right timescale" do
          expect(entity.timescale).to eq(1000)
        end

        it "has the right duration" do
          expect(entity.duration).to eq(60000)
        end

        it "has the right duration in seconds" do
          expect(entity.duration_in_s).to eq(60.0)
        end

        it "has the right rate" do
          expect(entity.rate).to eq(1.0)
        end

        it "has the right volume" do
          expect(entity.volume).to eq(1.0)
        end

        it "has the right matrix" do
          expect(entity.matrix).to eq(Matrix[
            [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]]
          ])
        end

        it "has the right next_track_id" do
          expect(entity.next_track_id).to eq(3)
        end
      end
    end
  end
end
