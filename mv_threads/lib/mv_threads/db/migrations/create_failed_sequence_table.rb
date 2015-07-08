require 'active_record'

class CreateFailedSequenceTable < ActiveRecord::Migration
  def change
    create_table :failed_sequences do |t|
      # the sequence id
      t.integer :sequence_id

      # the raw data bytes received from the TCP/IP tunnel
      t.text :data_bytes

      # the error type raised at parsing time
      t.integer :error_type

      # adding tha classic rails timestamps
      t.timestamps
    end
  end
end