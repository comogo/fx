require "spec_helper"
require "fx/schema/statements"

describe Fx::Schema::Statements, :db do
  describe "#create_function" do
    it "creates a function from a file" do
      database = stubbed_database
      definition = stubbed_definition

      connection.create_function(:test)

      expect(database).to have_received(:create_function).with(definition.to_sql)
      expect(Fx::Definition).to have_received(:new).with(:test, 1)
    end

    it "allows creating a function with a specific version" do
      database = stubbed_database
      definition = stubbed_definition

      connection.create_function(:test, version: 2)

      expect(database).to have_received(:create_function).with(definition.to_sql)
      expect(Fx::Definition).to have_received(:new).with(:test, 2)
    end

    it "raises an error if both arguments are nil" do
      expect {
        connection.create_function(
          :whatever,
          version: nil,
          sql_definition: nil,
        )
      }.to raise_error ArgumentError
    end
  end

  describe "#drop_function" do
    it "drops the function" do
      database = stubbed_database

      connection.drop_function(:test)

      expect(database).to have_received(:drop_function).with(:test)
    end
  end

  describe "#update_function" do
    it "updates the function" do
      database = stubbed_database
      definition = stubbed_definition

      connection.update_function(:test, version: 3)

      expect(database).to have_received(:drop_function).with(:test)
      expect(database).to have_received(:create_function).
        with(definition.to_sql)
      expect(Fx::Definition).to have_received(:new).with(:test, 3)
    end

    it "raises an error if not supplied a version" do
      expect { connection.update_function(:test) }.
        to raise_error(ArgumentError, /version is required/)
    end
  end

  def stubbed_database
    instance_spy("StubbedDatabase").tap do |stubbed_database|
      allow(Fx).to receive(:database).and_return(stubbed_database)
    end
  end

  def stubbed_definition
    instance_double("Fx::Definition", to_sql: "foo").tap do |stubbed_definition|
      allow(Fx::Definition).to receive(:new).and_return(stubbed_definition)
    end
  end
end
