# typed: false
require 'spec_helper'

RSpec.describe Kirei::Model::ClassMethods do
  describe '#vector_column?' do
    let(:model_class) do
      Class.new(T::Struct) do
        include Kirei::Model
        const :id, String
      end
    end

    let(:db_double) { instance_double(Sequel::Database) }

    before do
      allow(model_class).to receive(:db).and_return(db_double)
      allow(db_double).to receive(:schema).with(model_class.table_name.to_sym).and_return([
        [:id, { db_type: 'text' }],
        [:embedding, { db_type: 'vector(3)' }]
      ])
    end

    it 'returns false for an unknown column' do
      expect(model_class.vector_column?('unknown')).to be(false)
    end
  end
end
