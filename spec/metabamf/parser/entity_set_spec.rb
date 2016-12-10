require 'metabamf/parser/entity_set.rb'

module Metabamf::Parser
  RSpec.describe EntitySet do
    let(:entity) { double(boxtype: 'fltc') }

    it "can have entities added as an Array" do
      expect(subject << entity).to be(subject)
    end

    it "can have entities returned as an array" do
      subject << entity
      expect(subject.to_a).to eq([entity])
    end

    it "can return a single entity by boxtype" do
      subject << entity
      expect(subject.fetch('fltc')).to be(entity)
    end

    it "can return an array of entities with the same boxtype" do
      subject << entity << entity
      expect(subject.fetch_group('fltc')).to eq([entity, entity])
    end
  end
end
