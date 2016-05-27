defmodule Jaqen.Markov do
  import Logger

  def generate(input) do
    tmp_path = "/tmp/jaqen_#{:rand.uniform(1000)}"

    File.write(tmp_path, input)
    markoved = case System.cmd("marky_markov", ["speak", "-s", tmp_path, "-c", "#{:rand.uniform(5)}"]) do
      {markoved, 0} ->
        markoved
      {_,  code} ->
        warn("code #{code} from marky. tmp_path is #{tmp_path}")
        ""
    end

    File.rm(tmp_path)
    markoved
  end
end
