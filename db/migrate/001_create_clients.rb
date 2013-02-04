Sequel.migration do
  change do
    create_table(:clients) do
      primary_key :id
      String :client_id, null: false
    end
  end
end
