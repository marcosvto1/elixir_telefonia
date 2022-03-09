defmodule Pospago do
  defstruct value: 0

  @custo_minuto 1.40

  def fazer_chamada(numero, data, duracao) do
    Assinante.buscar_assinante(numero, :pospago)
    |> Chamada.registrar(data, duracao)

    {:ok, "Chamada feita com sucesso! com duração de #{duracao} minutos"}
  end

  def imprimir_conta(mes, ano, numero) do
    assinante = Contas.imprimir(mes, ano, numero, :pospago)
    
    valor = assinante.chamadas
    |> Enum.map(&(&1.duracao * @custo_minuto))
    |> Enum.sum()

    plano = %__MODULE__{value: valor}

    assinante = %Assinante{assinante | plano: plano }
  end
end