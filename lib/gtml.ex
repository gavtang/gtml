defmodule Gtml do
  @moduledoc """
  No frills component rendering system for HTML in Elixir.
  Saves HTML files into memory and replaces tags in <@ComponentName> format
  with the content of ComponentName.html in the initialized folder, recursively
  """

  require Logger

  def start(target_folder \\ ".") do
    Logger.info("starting GTML")
    :ets.new(:gtml_raw_components, [:set, :protected, :named_table])
    :ets.new(:gtml_components, [:set, :protected, :named_table])

    crawl_folder(target_folder)
    |> Enum.map(&save_raw/1)
    |> Enum.each(fn {component, fileContent} ->
      :ets.insert(:gtml_components, {component, render(fileContent)})
    end)

    :ok
  end

  def crawl_folder(path) do
    case File.ls(path) do
      {:ok, items} ->
        {dirs, files} = Enum.split_with(items, &File.dir?(Path.join(path, &1)))
        file_paths = Enum.map(files, &Path.join(path, &1))

        dirs
        |> Enum.map(&Path.join(path, &1))
        |> Enum.flat_map(&crawl_folder/1)
        |> Enum.concat(file_paths)
        |> Enum.filter(&(Path.extname(&1) == ".html"))

      _ ->
        []
    end
  end

  def save_raw(path) do
    case File.read(path) do
      {:ok, fileContent} ->
        component = Path.basename(path, ".html")
        trimmedContent = String.trim(fileContent)
        :ets.insert(:gtml_raw_components, {component, trimmedContent})
        {component, trimmedContent}
    end
  end

  def load_raw(key) do
    [{_component, fileContent} | _] = :ets.lookup(:gtml_raw_components, key)
    fileContent
  end

  def load(key) do
    [{_component, fileContent} | _] = :ets.lookup(:gtml_components, key)
    fileContent
  end

  def render(str_content), do: render(String.to_charlist(str_content), [])
  # to string?
  def render([], out), do: List.to_string(out)
  def render([?<, ?@ | rest], out), do: read_component(rest, out, [])
  def render([char | rest], out), do: render(rest, out ++ [char])

  def read_component([?\s | rest], out, component), do: read_component(rest, out, component)

  def read_component([?> | rest], out, component),
    do: insert_component(rest, out, List.to_string(component))

  def read_component([char | rest], out, component),
    do: read_component(rest, out, component ++ [char])

  def insert_component(rest, out, component_name) do
    # TODO: check loaded content first to reduce double rendering 
    content = load_raw(component_name) |> String.to_charlist()
    render(content ++ rest, out)
  end
end
