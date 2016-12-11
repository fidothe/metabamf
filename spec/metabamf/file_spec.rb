require 'metabamf/file'
require 'metabamf/parser/entity_set'

module Metabamf
  RSpec.describe File do
    let(:ftyp) { double(boxtype: 'ftyp') }
    let(:pdin) { double(boxtype: 'pdin') }
    let(:moov) { double(boxtype: 'moov') }
    let(:entity_set) { Parser::EntitySet.new << ftyp << pdin << moov }

    subject { File.new(entity_set) }

    it "can return its ftyp box" do
      expect(subject.ftyp).to be(ftyp)
    end

    it "can report that it has an ftyp box" do
      expect(subject.has_ftyp?).to be(true)
    end

    it "can return its pdin box" do
      expect(subject.pdin).to be(pdin)
    end

    it "can report that it has a pdin box" do
      expect(subject.has_pdin?).to be(true)
    end

    it "can return its moov box" do
      expect(subject.moov).to be(moov)
    end

    it "can report that it has a moov box" do
      expect(subject.has_moov?).to be(true)
    end

    it "can iterate over its boxes" do
      expect(subject.each.map { |b| b }).to eq([ftyp, pdin, moov])
    end
  end
end
