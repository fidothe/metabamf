require 'metabamf/parser/entity_set.rb'

module Metabamf::Parser
  RSpec.describe EntitySet do
    let(:entity) { double(boxtype: 'fltc') }

    it "can have entities added as an Array" do
      expect(subject << entity).to be(subject)
    end

    it "supports #[] access to the entities" do
      subject << entity
      expect(subject[0]).to eq(entity)
    end

    it "supports #each iteration" do
      subject << entity
      collector = []
      subject.each do |en|
        collector << en
      end
      expect(collector).to eq([entity])
    end

    it "returns its size" do
      subject << entity
      expect(subject.size).to eq(1)
      expect(subject.length).to eq(1)
    end

    it "can return a single entity by boxtype" do
      subject << entity
      expect(subject.fetch('fltc')).to be(entity)
    end

    it "can return an array of entities with the same boxtype" do
      subject << entity << entity
      expect(subject.fetch_group('fltc')).to eq([entity, entity])
    end

    it "includes Enumerable" do
      subject << entity
      expect(subject.first).to be(entity)
    end

    it "also implements #last" do
      second_entity = double(boxtype: 'fltc')
      subject << entity << second_entity

      expect(subject.last).to be(second_entity)
    end
  end
end
