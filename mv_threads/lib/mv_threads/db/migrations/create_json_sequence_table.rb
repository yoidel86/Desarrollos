require 'active_record'

class CreateJsonSequenceTable < ActiveRecord::Migration
  def change
    create_table :json_sequences do |t|
      # the sequence id
      t.integer :sequence_id

      # the hour information
      t.datetime :generated_timestamp

      # the parsed sequence from the TCP/IP tunnel
      t.text :message_type

      # the parsed sequence from the TCP/IP tunnel
      t.text :emitter

      # the parsed sequence in JSON from the TCP/IP tunnel
      t.json :json_data
    end
  end
end