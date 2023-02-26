defmodule EctoMultiRepo.WatchDog do
  @moduledoc false

  def start_watching(timeout) do
    spawn_link(fn -> watch(timeout) end)
  end

  def im_alive(watcher) do
    send(watcher, :im_alive)
  end

  defp watch(timeout) do
    receive do
      :im_alive ->
        watch(timeout)
    after
      timeout ->
        Process.exit(self(), {:shutdown, :watchdog_triggered})
    end
  end
end
