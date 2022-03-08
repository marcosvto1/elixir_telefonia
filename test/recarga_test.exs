defmodule RecargaTest do
  use ExUnit.Case
  doctest Recarga

  setup do
    File.write("pre.txt", :erlang.term_to_binary([]))
    File.write("pos.txt", :erlang.term_to_binary([]))

    on_exit(fn -> 
      File.rm("pre.txt")
      File.rm("pos.txt")
    end)
  end

  describe "Funções de Recarga" do
    test "deve fazer uma recarga" do
      Assinante.cadastrar("Marcos", "123", "0423", :prepago)
      assinante = Assinante.buscar_assinante("123", :prepago)
      assert Recarga.nova(DateTime.utc_now, 30, assinante.numero) == {:ok, "Recarga realiza com sucesso"}

      assinante = Assinante.buscar_assinante("123", :prepago)
      plano = assinante.plano
      recargas = plano.recargas
      assert plano.creditos == 40
      assert Enum.count(recargas) == 1
    end
  end

end