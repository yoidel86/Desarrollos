require 'active_record'

class CreateParsedSequenceTable < ActiveRecord::Migration
  def change
    create_table :parsed_sequences do |t|
      # the parsed sequence from the TCP/IP tunnel
      t.text :message_type

      # the parsed sequence from the TCP/IP tunnel
      t.text :emitter

      # the parsed sequence from the TCP/IP tunnel
      t.text :parsed_sequence

      # adding tha classic rails timestamps
      t.timestamps
    end
  end
end