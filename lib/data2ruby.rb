# frozen_string_literal: true
require 'active_model'

module Data2ruby
  include Enumerable

  module ClassMethods

    def associations
      @_associations ||= []
    end

    def has_one(label, &block)
      attr_writer(label)
      associations << label
      klass = build_assoc_class(&block)
      assoc_instance_builder = build_assoc_instance_builder(klass)
      inst_var_memo = "@_has_one_#{label}"

      define_method(label) do
        memoize(inst_var_memo) { assoc_instance_builder.(data[label]) }
      end
    end

    def has_many(label, &block)
      attr_writer(label)
      associations << label
      klass = build_assoc_class(&block)
      assoc_instance_builder = build_assoc_instance_builder(klass)
      inst_var_memo = "@_has_many_#{label}"

      define_method(label) do
        memoize(inst_var_memo) do
          data[label].map do |item|
            assoc_instance_builder.(item)
          end
        end
      end
    end

  private

    def build_assoc_class(&block)
      Class.new do
        include ActiveModel::Model
        include Data2ruby
        extend ActiveModel::Naming

        def self.name
          'AnonAssociation'
        end

        def name
          self.class.name
        end
      end
        .tap { |klass| klass.class_exec(&block) }
    end

    def build_assoc_instance_builder(klass)
      lambda do |data|
        klass.new(data).tap do |obj|
          obj.define_singleton_method(:data) { data }
        end
      end
    end
  end # module ClassMethods

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  def data
    raise NotImplementedError, 'Implement in the including class'
  end

  def each(&block)
    self.class.associations.each do |assoc_name|
      object = public_send(assoc_name)
      object.is_a?(Array) ? object.each(&block) : block.yield(object)
    end
  end

  def invalid_items
    reduce(select { |item| item.errors.any? }) do |sum, item|
      sum + item.invalid_items
    end
  end

  def valid_structure?
    reduce(respond_to?(:valid?) ? valid? : true) do |sum, item|
      item.valid_structure? && sum # forces to evaluate validity for all the nodes
    end
  end

private

  def memoize(var_name, &block)
    if instance_variable_defined?(var_name)
      instance_variable_get(var_name)
    else
      instance_variable_set(
        var_name,
        instance_exec(&block)
      )
    end
  end
end
