require 'metabamf/structure/definition'

module Metabamf::Structure
  RSpec.describe Definition do
    it "has a boxtype" do
      subject = Definition.new('moov')

      expect(subject.boxtype).to eq('moov')
    end

    it "can specify a mandatory simple attribute" do
      subject = Definition.new('fltc') do |d|
        d.attr :blah, required: true
      end

      expect(subject.simple_attributes[:blah]).to eq(required: true)
    end

    it "can specify an optional simple attribute" do
      subject = Definition.new('fltc') do |d|
        d.attr :blah
      end

      expect(subject.simple_attributes[:blah]).to eq(required: false)
    end

    context "a child box which can only occur once" do
      it "can be specified as mandatory" do
        subject = Definition.new('fltc') do |d|
          d.contains :blah, required: true
        end

        expected = {required: true, boxtype: 'blah'}
        expect(subject.contained_single_boxes[:blah]).to eq(expected)
      end

      it "can be specifed as optional" do
        subject = Definition.new('fltc') do |d|
          d.contains :blah
        end

        expected = {required: false, boxtype: 'blah'}
        expect(subject.contained_single_boxes[:blah]).to eq(expected)
      end

      it "can have the boxtype explicitly specified" do
        subject = Definition.new('fltc') do |d|
          d.contains :blah, boxtype: 'oflc'
        end

        expected = {required: false, boxtype: 'oflc'}
        expect(subject.contained_single_boxes[:blah]).to eq(expected)
      end
    end

    context "child boxes which can occur multiple times" do
      it "can be specified as mandatory" do
        subject = Definition.new('fltc') do |d|
          d.contains_multiple :blah, boxtype: 'oflc', required: true
        end

        expected = {required: true, boxtype: 'oflc'}
        expect(subject.contained_multiple_boxes[:blah]).to eq(expected)
      end

      it "can be specifed as optional" do
        subject = Definition.new('fltc') do |d|
          d.contains_multiple :blah, boxtype: 'oflc'
        end

        expected = {required: false, boxtype: 'oflc'}
        expect(subject.contained_multiple_boxes[:blah]).to eq(expected)
      end

      it "must have the boxtype explicitly specified" do
        expect {
          Definition.new('fltc') do |d|
            d.contains_multiple :blah
          end
        }.to raise_error(ExplicitBoxtypeRequired)
      end
    end

    context "generating an entity class" do
      let(:definition) {
        Definition.new('fltc') do |d|
          d.attr :hello, required: true
          d.attr :what
          d.contains :blah
          d.contains :also, required: true
          d.contains_multiple :fings, boxtype: 'fing'
        end
      }
      let(:other_box) { double }
      let(:entity_class) { definition.entity }
      let(:attrs) { Hash[
        hello: 'hello',
        what: 'what',
        also: other_box,
      ] }
      subject { entity_class.new(attrs) }

      it "provides optional attributes with a query method" do
        expect(subject.what?).to be(true)
        expect(subject.blah?).to be(false)
      end

      it "represents multiply-occuring child boxes as an array" do
        expect(subject.fings).to eq([])
      end

      it "raises an error if instantiated missing a mandatory attribute" do
        bad_attrs = attrs.dup
        bad_attrs.delete(:hello)
        expect {
          entity_class.new(bad_attrs)
        }.to raise_error(Metabamf::Entity::MissingRequiredAttribute)
      end

      it "raises an error if instantiated missing a mandatory child" do
        bad_attrs = attrs.dup
        bad_attrs.delete(:also)
        expect {
          entity_class.new(bad_attrs)
        }.to raise_error(Metabamf::Entity::MissingRequiredAttribute)
      end
    end
  end
end
