defmodule Contas do
  def imprimir(mes, ano, numero, plano) do
    assinante = Assinante.buscar_assinante(numero)
    chamada_do_mes = busca_elementos_mes(assinante.chamadas, mes, ano)

    cond do
      plano == :prepago -> 
        recargas_do_mes = busca_elementos_mes(assinante.plano.recargas, mes, ano)
        plano = %Prepago{assinante.plano | recargas: recargas_do_mes}
        %Assinante{assinante | chamadas: chamada_do_mes, plano: plano}

      plano == :pospago ->
        %Assinante{assinante | chamadas: chamada_do_mes}
    end

  end

  def busca_elementos_mes(elementos, mes, ano) do
    Enum.filter(
      elementos,
      &(&1.data.year === ano && &1.data.month === mes)
    )
  end
end
