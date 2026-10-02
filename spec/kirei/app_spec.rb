# typed: false

require "spec_helper"

RSpec.describe Kirei::App do
  describe ".raw_db_connection" do
    let(:config) { Kirei::Config.new(app_name: "dummy") }
    let(:database) { Sequel.mock }

    around do |example|
      previous_connection = described_class.instance_variable_get(:@raw_db_connection)
      previous_config = Kirei.configuration
      described_class.instance_variable_set(:@raw_db_connection, nil)
      Kirei.configuration = config
      example.run
    ensure
      described_class.instance_variable_set(:@raw_db_connection, previous_connection)
      Kirei.configuration = previous_config
    end

    before do
      allow(database).to receive(:extension)
      allow(database).to receive(:wrap_json_primitives=)
      allow(Sequel).to receive(:connect).and_return(database)
      allow(Sequel).to receive(:extension)
    end

    it "connects without pool options by default", :aggregate_failures do
      described_class.raw_db_connection

      expect(Sequel).to have_received(:connect).with(described_class.default_db_url, {})
      expect(Sequel).not_to have_received(:extension)
      expect(database).to have_received(:extension).with(:pg_json)
      expect(database).to have_received(:extension).with(:pg_array)
    end

    it "loads global extensions before connecting and passes pool options", :aggregate_failures do
      config.db_global_extensions = [:fiber_concurrency]
      config.db_max_connections = 7
      config.db_pool_timeout = 1.5
      config.db_connect_timeout = 3
      config.db_connect_sqls = ["SET statement_timeout = '10s'"]

      described_class.raw_db_connection

      expect(Sequel).to have_received(:extension).with(:fiber_concurrency).ordered
      expect(Sequel).to have_received(:connect).with(
        described_class.default_db_url,
        {
          max_connections: 7,
          pool_timeout: 1.5,
          connect_timeout: 3,
          connect_sqls: ["SET statement_timeout = '10s'"],
        },
      ).ordered
    end

    it "memoizes the connection" do
      first = described_class.raw_db_connection
      second = described_class.raw_db_connection

      expect(second).to be(first)
      expect(Sequel).to have_received(:connect).once
    end
  end
end
