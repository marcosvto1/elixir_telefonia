defmodule ChamadaTest do
  use ExUnit.Case


  test "Deve testar a estrutura" do
    assert %Chamada{data: DateTime.utc_now(), duracao: 30}.duracao == 30
  end
end