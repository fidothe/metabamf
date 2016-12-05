require 'metabamf/entity/errors'

module Metabamf
  module Entity
    class Generator
      def self.generate(attrs)
        new(attrs).generate
      end

      attr_reader :optional, :required, :multiple_box, :query

      def initialize(attrs)
        @optional = attrs.fetch(:optional)
        @required = attrs.fetch(:required)
        @multiple_box = attrs.fetch(:multiple_box)
        @query = attrs.fetch(:query)
      end

      def attrs
        optional + required
      end

      def generate
        set_attribute_class_instance_vars
        define_methods_and_readers
        klass
      end

      def klass
        @klass ||= Class.new do
          include Entity::Common
        end
      end

      def set_attribute_class_instance_vars
        klass.instance_variable_set(:@optional_attributes, optional)
        klass.instance_variable_set(:@required_attributes, required)
        klass.instance_variable_set(:@multiple_box_attributes, multiple_box)
      end

      def define_methods_and_readers
        klass.send(:attr_reader, *attrs)

        klass.class_eval <<-EOS
          def attributes
            {#{attrs.map { |attr| "#{attr}: @#{attr}" }.join(', ')}}
          end
        EOS

        query.each do |name|
          klass.class_eval <<-EOS
            def #{name}?
              !!#{name}
            end
          EOS
        end
      end
    end

    module Common
      module ClassMethods
        def optional_attributes
          @optional_attributes
        end

        def required_attributes
          @required_attributes
        end

        def multiple_box_attributes
          @multiple_box_attributes
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      def initialize(attrs)
        attributes = {}
        self.class.optional_attributes.each do |name|
          attributes[name] = attrs[name] if attrs[name]
        end
        self.class.required_attributes.each do |name|
          raise Entity::MissingRequiredAttribute unless attrs.has_key?(name)
          attributes[name] = attrs[name]
        end
        self.class.multiple_box_attributes.each do |name|
          instance_variable_set(:"@#{name}", [])
        end

        attributes.each do |name, value|
          instance_variable_set(:"@#{name}", value)
        end
      end

      def ==(other)
        other.attributes == attributes
      end
    end

    def self.generate(attrs)
      Generator.generate(attrs)
    end
  end
end
