defmodule Tds.Packet.Token do
  import Bitwise

  @tokens [
    {0x88, :alt_metadata},
    {0xD3, :alt_row},
    {0x81, :col_metadata},
    {0xA5, :col_info},
    {0xFD, :done},
    {0xFE, :done_proc},
    {0xFF, :done_in_proc},
    {0xE3, :env_change},
    {0xAA, :error},
    {0xAE, :feature_ext_ack},
    {0xEE, :fed_auth_info},
    {0xAB, :info},
    {0xAD, :login_ack},
    {0xD2, :nbc_row},
    {0x78, :offset},
    {0xA9, :order},
    {0x79, :return_status},
    {0xAC, :return_value},
    {0xD1, :row},
    {0xED, :sspi},
    {0xA4, :tab_name}
  ]

  @doc """
  Decodes given TDS packet data
  """
  @spec parse(<<_::8, _::_*8>>) :: {:ok, struct, binary} | {:error, any}
  Enum.map(@tokens, fn {token, module} ->
    def parse(<<unquote(token), tail::binary>>),
      do: apply(unquote(module), :parse, [tail])
  end)

  def parse(<<token, _tail::binary>>),
    do:
      {:error, "Unknown TDS packed data token: #{Integer.to_string(token, 16)}"}

  def class(token) when token > 0 and token < 0xFF do
    case token &&& 0b00110000 do
      0b0000_0000 -> {:variable, :count}
      0b0001_0000 -> {:fixed, 0}
      0b0010_0000 -> {:variable, :length}
      0b0011_0000 -> {:fixed, 1}
      0b0011_0100 -> {:fixed, 2}
      0b0011_1000 -> {:fixed, 4}
      0b0011_1100 -> {:fixed, 8}
    end
  end

end