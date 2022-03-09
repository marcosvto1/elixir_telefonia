defmodule PospagoTest do
  use ExUnit.Case

  test "deve usar a strutura" do
    assert %Pospago{value: 1}.value == 1
  end
 
end