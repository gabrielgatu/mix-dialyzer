use Mix.Config

config :logger, level: (case Mix.env do
    :test -> :error
    _ -> :info
  end)
