defmodule GtmlTest do
  use ExUnit.Case
  doctest Gtml

  test "reads_files" do
    :ets.new(:gtml_raw_components, [:set, :protected, :named_table])
    read = Gtml.save_raw("./test/bar.html")
    assert read == {"bar", "bar"}
  end

  test "trims_content" do
    :ets.new(:gtml_raw_components, [:set, :protected, :named_table])
    read = Gtml.save_raw("./test/spacebar.html")
    assert read == {"spacebar", "bar"}
  end

  test "initializes" do
    assert Gtml.start("./test") == :ok
  end

  test "initializes_default" do
    assert Gtml.start() == :ok
  end

  test "crawls_folders" do
    assert Gtml.crawl_folder("./test") |> Enum.sort() ==
             ["./test/bar.html", "./test/foo.html", "./test/spacebar.html"] |> Enum.sort()
  end

  test "loads_raw_content" do
    Gtml.start("./test")
    assert Gtml.load_raw("bar") == "bar"
  end

  test "renders_content" do
    Gtml.start("./test")
    assert Gtml.render("<@bar>") == "bar"
  end

  test "loads_content" do
    Gtml.start(~c"./test")
    assert Gtml.load("foo") == "Foo bar"
  end
end
