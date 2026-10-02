# typed: false

require "spec_helper"

module CreateSpecDummy
  class Record < T::Struct
    include Kirei::Model

    const :id, String
    const :name, String
    const :kind, String, default: "default"
  end
end

RSpec.describe Kirei::Model, ".create" do
  let(:db) { Sequel.mock(host: "postgres", fetch: { id: id, name: "example", kind: "default" }).extension(:pg_json) }

  shared_context "with a mocked database" do
    before { allow(Kirei::App).to receive(:raw_db_connection).and_return(db) }
  end

  context "without an id" do
    include_context "with a mocked database"
    let(:id) { "record_abcdefghjkmn" }

    it "generates a human id, inserts it, and loads the record by it", :aggregate_failures do
      allow(CreateSpecDummy::Record).to receive(:generate_human_id).and_return(id)

      record = CreateSpecDummy::Record.create(name: "example")
      sqls = db.sqls

      expect(sqls.first).to include('INSERT INTO "records"')
      expect(sqls.first).to include("'record_abcdefghjkmn'")
      expect(sqls.last).to include(%(("id" = 'record_abcdefghjkmn')))
      expect(record.id).to eq(id)
    end
  end

  context "with a caller-provided id" do
    include_context "with a mocked database"
    let(:id) { "custom" }

    it "keeps the id and applies model defaults", :aggregate_failures do
      record = CreateSpecDummy::Record.create(id: "custom", name: "example")
      insert = db.sqls.first

      expect(insert).to include("'custom'")
      expect(insert).to include("'default'")
      expect(record.id).to eq("custom")
      expect(record.kind).to eq("default")
    end
  end

  describe ".generate_human_id" do
    it "defaults to a 12-character suffix" do
      expect(CreateSpecDummy::Record.generate_human_id).to match(/\Arecord_[A-Za-z0-9]{12}\z/)
    end
  end
end
