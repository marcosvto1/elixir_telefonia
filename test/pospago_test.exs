defmodule PospagoTest do
  use ExUnit.Case
  
  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn -> 
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  test "deve usar a strutura" do
    assert %Pospago{value: 1}.value == 1
  end

  test "Deve fazer uma ligacao" do
    Assinante.cadastrar("Marcos", "123", "123", :pospago)
    assert Pospago.fazer_chamada("123", DateTime.utc_now(), 5) == {:ok, "Chamada feita com sucesso! com duração de 5 minutos"}
    assinante = Assinante.buscar_assinante("123", :pospago)

    assert Enum.count(assinante.chamadas) == 1
  end

  describe "Testes para impressao de contas" do
    test "deve imprimir a conta do assinante" do
      Assinante.cadastrar("Marcos", "123", "123", :pospago)

      data = DateTime.utc_now()
      data_antiga = ~U[2022-02-01 00:37:30.362220Z]
      Pospago.fazer_chamada("123", data_antiga, 10) 
      Pospago.fazer_chamada("123", data, 10) 
      Pospago.fazer_chamada("123", data, 10) 
      
      assinante = Assinante.buscar_assinante("123")
      assert assinante.numero == "123"
      assert Enum.count(assinante.chamadas) == 3

      assinante = Pospago.imprimir_conta(data.month, data.year, "123")
      assert assinante.numero == "123"
      assert Enum.count(assinante.chamadas) == 2
      assert assinante.plano.value == 28.0
    end
  end
 
end