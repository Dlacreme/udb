defmodule UDB.Config do
  @config %{
    :db => %{
      :adapter => System.get_env("DB_ADAPTER"),
      :hostname => System.get_env("DB_HOSTNAME"),
      :port => System.get_env("DB_PORT"),
      :username => System.get_env("DB_USERNAME"),
      :password => System.get_env("DB_PASSWORD"),
    }
  }

  def db, do: Map.fetch!(@config, :db)

  def validate() do
    validate_map(__MODULE__.db)
    :ok
  end

  defp validate_map(map) do
    for {k, v} <- map do
      if v == nil, do: raise "#{k} IS MISSING."
    end
  end

end
