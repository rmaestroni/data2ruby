# frozen_string_literal: true

RSpec.describe Data2ruby do
  let(:klass) do
    Class.new { include Data2ruby }
  end

  describe 'module' do
    context 'when included in a class' do
      it 'defines the has_one class method' do
        expect(klass).to be_respond_to(:has_one)
      end

      it 'defines the has_many class method' do
        expect(klass).to be_respond_to(:has_many)
      end
    end
  end

  describe 'data' do
    let(:instance) { klass.new }

    it 'is not implemented' do
      expect { instance.data }.to raise_error(NotImplementedError)
    end
  end

  describe 'test fixture' do
    let(:tree_class) do
      Class.new do
        include Data2ruby

        attr_reader :data

        def initialize(data)
          @data = data
        end

        has_one :item do
          attr_accessor :attr1
          validates_presence_of :attr1

          has_many :subitems do
            attr_accessor :attr2
            validates_presence_of :attr2
          end
        end
      end
    end

    let(:instance) do
      tree_class.new(item: { attr1: 'value', subitems: [{ attr2: 'value' }] })
    end

    describe 'associations' do
      it 'is possible to navigate through them' do
        expect(instance.item.attr1).to eq('value')
        expect(instance.item.subitems[0].attr2).to eq('value')
      end
    end

    describe 'validation' do
      it 'passes' do
        expect(instance).to be_valid_structure
        expect(instance.invalid_items).to be_blank
      end

      context 'with some missing attribute' do
        let(:instance) do
          tree_class.new(item: { attr1: 'value', subitems: [{ attr2: '' }] })
        end

        it 'fails' do
          expect(instance).not_to be_valid_structure
          expect(instance.invalid_items).not_to be_blank
        end
      end
    end
  end
end
