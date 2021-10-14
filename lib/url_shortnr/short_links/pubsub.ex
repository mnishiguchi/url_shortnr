defmodule UrlShortnr.ShortLinks.PubSub do
  @topic inspect(__MODULE__)

  @doc """
  Subscribe to this context's messages.
  """
  def subscribe do
    Phoenix.PubSub.subscribe(UrlShortnr.PubSub, @topic)
  end

  @doc """
  Broadcast a message to the subscribers when a record is inserted or updated.
  """
  def broadcast_record({:ok, record}, event) when is_struct(record) do
    Phoenix.PubSub.broadcast(UrlShortnr.PubSub, @topic, {event, record})
    {:ok, record}
  end

  def broadcast_record({:error, reason}, _event), do: {:error, reason}
end
