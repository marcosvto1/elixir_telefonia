defmodule PrepagoTest do
  use ExUnit.Case
  doctest Prepago

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn -> 
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  describe "Funcções de Ligacao" do
    test "fazer uma ligação" do
      Assinante.cadastrar("Marcos", "123", "0423", :prepago)
      assert Prepago.fazer_chamada("123", DateTime.utc_now(), 3) == {:ok, "A chamada custou 4.35 e voce tem 5.65 de creditos"} 
    end
    
    test "fazer uma ligação longa e não tem creditos" do
      Assinante.cadastrar("Marcos", "123", "0423", :prepago)
      assert Prepago.fazer_chamada("123", DateTime.utc_now(), 10) == {:error, "Voce nao tem credido para a ligacao, faça uma recarga"} 
    end
  end

  describe "Testes para impressao de contas" do
    test "deve informar valores da conta do mes" do
      Assinante.cadastrar("Marcos", "123", "123", :prepago)

      data = DateTime.utc_now()
      data_antiga = ~U[2022-02-01 00:37:30.362220Z]
      Recarga.nova(data_antiga, 10, "123")
      Prepago.fazer_chamada("123", data_antiga, 10) 

      Recarga.nova(data, 10, "123")
      Prepago.fazer_chamada("123", data, 10) 
      
      assinante = Assinante.buscar_assinante("123")
      assert assinante.numero == "123"
      assert Enum.count(assinante.chamadas) == 2
      assert Enum.count(assinante.plano.recargas) == 2

      assinante = Prepago.imprimir_conta(data.month, data.year, "123")
      assert assinante.numero == "123"
      assert Enum.count(assinante.chamadas) == 1
      assert Enum.count(assinante.plano.recargas) == 1
    end
  end

end