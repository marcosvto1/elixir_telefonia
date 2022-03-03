defmodule AssinanteTest do
  use ExUnit.Case
  doctest Assinante

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn -> 
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  test "Deve retornar a estrutura de assinante" do
    assert %Assinante{nome: "Teste", numero: "123", cpf: "45645465", plano: :pospago}.nome == "Teste"
  end

  describe "Testes responsaveis para cadastro de assinates" do
    test "criar uma conta prepago" do
      assert Assinante.cadastrar("Marcos", "123", "0423") == {:ok, "Assiante Marcos cadastrado com sucesso"}
    end
   
    test "deve retorna erro dizendo que o usuário já esta cadastrado" do
      Assinante.cadastrar("Marcos", "123", "0423") 

      assert Assinante.cadastrar("Marcos", "123", "0423") == {:error, "Assinante com este número cadastrado"}
    end
  end

  describe "Teste reponsaveis por busca de assinantes" do
    test "busca pospago" do
      Assinante.cadastrar("Marcos", "123", "0423", :pospago) 

      assert Assinante.buscar_assinante("123", :pospago).nome == "Marcos"
    end

    test "busca prepago" do
      Assinante.cadastrar("Marcos", "123", "0423", :prepago) 

      assert Assinante.buscar_assinante("123", :prepago).nome == "Marcos"
    end

    test "busca em todos" do
      Assinante.cadastrar("Marcos", "123", "0423", :prepago) 

      assert Assinante.buscar_assinante("123").nome == "Marcos"
    end
  end


end
