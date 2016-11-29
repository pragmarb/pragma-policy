# frozen_string_literal: true
RSpec.describe Pragma::Policy::AttributeAuthorizer do
  before(:all) do
    module Reform
      class Form < OpenStruct
      end
    end

    module ActiveRecord
      class Base < OpenStruct
      end
    end
  end

  let(:activerecord_klass) { Class.new(ActiveRecord::Base) }
  let(:reform_klass) { Class.new(Reform::Form) }

  def build_activerecord_resource(old_value, new_value)
    activerecord_klass.new(
      status: new_value,
      status_was: old_value
    )
  end

  def build_reform_resource(old_value, new_value)
    reform_klass.new(
      status: new_value,
      model: activerecord_klass.new(
        status: old_value
      )
    )
  end

  def build_authorizer(resource)
    described_class.new(resource: resource, attribute: :status)
  end

  describe '#old_value' do
    context 'with a Reform form' do
      let(:resource) { build_reform_resource('draft', 'published') }

      it 'reads the old value correctly' do
        expect(build_authorizer(resource).old_value).to eq('draft')
      end
    end

    context 'with an ActiveRecord record' do
      let(:resource) { build_activerecord_resource('draft', 'published') }

      it 'reads the old value correctly' do
        expect(build_authorizer(resource).old_value).to eq('draft')
      end
    end
  end

  describe '#new_value' do
    context 'with a Reform form' do
      let(:resource) { build_reform_resource('draft', 'published') }

      it 'reads the old value correctly' do
        expect(build_authorizer(resource).new_value).to eq('published')
      end
    end

    context 'with an ActiveRecord record' do
      let(:resource) { build_activerecord_resource('draft', 'published') }

      it 'reads the old value correctly' do
        expect(build_authorizer(resource).new_value).to eq('published')
      end
    end
  end

  describe '#authorize' do
    context 'with no options' do
      it 'returns true when the attibute was not changed' do
        resource = build_activerecord_resource('draft', 'draft')
        authorizer = build_authorizer(resource)

        expect(authorizer.authorize).to be true
      end

      it 'returns false when the attribute was changed' do
        resource = build_activerecord_resource('draft', 'published')
        authorizer = build_authorizer(resource)

        expect(authorizer.authorize).to be false
      end
    end

    context 'with the :only option' do
      it 'returns true when the attibute was not changed' do
        resource = build_activerecord_resource('published', 'published')
        authorizer = build_authorizer(resource)

        expect(authorizer.authorize(only: [:draft])).to be true
      end

      it 'returns true when the new value is part of the allowed values' do
        resource = build_activerecord_resource('published', 'draft')
        authorizer = build_authorizer(resource)

        expect(authorizer.authorize(only: [:draft])).to be true
      end

      it 'returns false when the new value is not part of the allowed values' do
        resource = build_activerecord_resource('draft', 'published')
        authorizer = build_authorizer(resource)

        expect(authorizer.authorize(only: [:draft])).to be false
      end
    end

    context 'with the :except option' do
      it 'returns true when the attibute was not changed' do
        resource = build_activerecord_resource('published', 'published')
        authorizer = build_authorizer(resource)

        expect(authorizer.authorize(except: [:published])).to be true
      end

      it 'returns true when the new value is not part of the excluded values' do
        resource = build_activerecord_resource('published', 'draft')
        authorizer = build_authorizer(resource)

        expect(authorizer.authorize(except: [:published])).to be true
      end

      it 'returns false when the new value is part of the excluded values' do
        resource = build_activerecord_resource('draft', 'published')
        authorizer = build_authorizer(resource)

        expect(authorizer.authorize(except: [:published])).to be false
      end
    end
  end
end
