defmodule Assinante do
  @moduledoc """
    Module de assinante para cadastro de tipos de assinantes como `prepago` e `pospago`

    A Função mais utilizada e a função `cadastrar/4`
  """

  defstruct nome: nil, numero: nil, cpf: nil, plano: nil, chamadas: []

  @assinantes %{:prepago => "pre.txt", :pospago => "pos.txt"}

  @doc """
  Função para cadastrar assinante seja ele `prepago` e `pospago`

  ## Parametros da Função

  - nome: parametro do nome do assinante
  - numero: número unico e caso exista pode returna um erro
  - cpf: parametro de assiante
  - plano: opcional e caso não seja informado sera considerado `prepago`


  ## Informaçoes Adicionais

  - Caso o número já exista ele exibira uma mensagem de erro

  ## Exemplo


      iex> Assinante.cadastrar("Joao", "1423123", "12312312312", :prepago)
      {:ok, "Assiante Joao cadastrado com sucesso"}
  """
  def cadastrar(nome, numero, cpf, :prepago), do: cadastrar(nome, numero, cpf, %Prepago{})
  def cadastrar(nome, numero, cpf, :pospago), do: cadastrar(nome, numero, cpf, %Pospago{})
  def cadastrar(nome, numero, cpf, plano) do
    case buscar_assinante(numero) do
      nil -> 
        assinante = %__MODULE__{nome: nome, numero: numero, cpf: cpf, plano: plano}
        (read(pega_plano(assinante)) ++ [assinante])
        |> :erlang.term_to_binary()
        |> write(pega_plano(assinante)) 

        {:ok, "Assiante #{nome} cadastrado com sucesso"}

      _assinante -> {:error, "Assinante com este número cadastrado"}
    end  
  end

  def atualizar(numero, assinante) do
    {assinante_antigo, nova_lista} = deletar_item(numero)

    case assinante.plano.__struct__ === assinante_antigo.__struct__ do
      true ->
        (nova_lista ++ [assinante])
        |> :erlang.term_to_binary()
        |> write(pega_plano(assinante)) 
      false ->
        {:error, "Assinante não pode alterar o plano"}
    end
  end

  defp pega_plano(assinante) do
    IO.inspect "Pegando um plano para #{assinante.numero}"
    case assinante.plano.__struct__ == Prepago do
      true -> :prepago
      false -> :pospago
    end
  end

  @doc """
  Função encontrar o assinante, seja por `pospago`, `prepago` ou por ambas

  ## Parametros da função

  - numero: Número do assinante
  - key: Tipo de lista, (:all, :prepago, :pospago), caso não informado será considerado :all

  ## Exemplo

      iex> Assinante.cadastrar("Joao", "123", "123", :prepago)
      iex> Assinante.buscar_assinante("123")
      %Assinante{cpf: "123", nome: "Joao", numero: "123", plano: %Prepago{creditos: 10, recargas: []}}

  """
  def buscar_assinante(numero, key \\ :all), do: buscar(numero, key)

  defp buscar(numero, :prepago), do: filtro(assinante_prepago(), numero)
  defp buscar(numero, :pospago), do: filtro(assinante_pospago(), numero)
  defp buscar(numero, :all), do: filtro(assinantes(), numero)
  defp filtro(lista, numero), do: Enum.find(lista, &(&1.numero == numero))

  def assinante_prepago, do: read(:prepago)

  def assinante_pospago, do: read(:pospago)

  def assinantes, do: read(:prepago) ++ read(:pospago)

  def deletar_assinante(numero) do
    {assinante, nova_lista} = deletar_item(numero)
   
    result_delete = nova_lista
    |> :erlang.term_to_binary()
    |> write(pega_plano(assinante))

    {result_delete, "Assinante removido com sucesso"}

    # case buscar_assinante(numero, key) do
    #     assinante -> 
    #       if assinante.plano == :pospago do
    #         write(List.delete(assinante_pospago(), assinante), assinante.plano)  
    #       else
    #         write(List.delete(assinante_prepago(), assinante), assinante.plano)  
    #       end
    #       {:ok, "Assinante removido com sucesso"}
    #     nil ->
    #       {:error, "Falha ao remover assinante"}
    # end
  end

  def deletar_item(numero) do
    IO.inspect "DELETE -- #{numero}"
    assinante = buscar_assinante(numero)
    nova_lista = read(pega_plano(assinante))
    |> List.delete(assinante)
    {assinante, nova_lista}
  end

  defp write(lista_assinantes, plano), do: File.write!(@assinantes[plano], lista_assinantes)

  def read(plano) do
    case File.read(@assinantes[plano]) do
      {:ok, assinantes} -> 
        assinantes
        |> :erlang.binary_to_term()
      {:error, :ennoent} -> {:error, "Arquivo inválido"}
    end
  end
end
