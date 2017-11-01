Sequel.migration do
  change do
    create_table(:shops) do
      primary_key :id
      String :name
      String :token_encrypted
      index :name
    end
  end
end
