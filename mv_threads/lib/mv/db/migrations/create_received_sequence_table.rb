require 'active_record'

class CreateReceivedSequenceTable < ActiveRecord::Migration
  def change
    create_table :received_sequences do |t|
      # the sequence id
      t.integer :sequence_id

      # the raw data bytes received from the TCP/IP tunnel
      t.text :data_bytes

      # adding tha classic rails timestamps
      t.timestamps
    end
  end
end


