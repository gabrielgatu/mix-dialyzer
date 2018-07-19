File.cd!("test/fixtures/base_project/", fn ->
  System.cmd("mix", ["deps.get"])
  System.cmd("mix", ["compile"])
  System.cmd("mix", ["dialyzer"])
end)

File.cd!("test/fixtures/complex_project/", fn ->
  System.cmd("mix", ["deps.get"])
  System.cmd("mix", ["compile"])
  System.cmd("mix", ["dialyzer"])
end)
