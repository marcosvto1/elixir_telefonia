defmodule Assinante do
  @moduledoc """
    Module de assinante para cadastro de tipos de assinantes como `prepago` e `pospago`

    A Função mais utilizada e a função `cadastrar/4`
  """

  defstruct nome: nil, numero: nil, cpf: nil, plano: nil

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


      iex> Assinante.cadastrar("Joao", "1423123", "12312312312")
      {:ok, "Assiante Joao cadastrado com sucesso"}
  """
  def cadastrar(nome, numero, cpf, plano \\ :prepago) do
    case buscar_assinante(numero) do
      nil -> (read(plano) ++ [%__MODULE__{nome: nome, numero: numero, cpf: cpf, plano: plano}])
        |> :erlang.term_to_binary()
        |> write(plano) 
        {:ok, "Assiante #{nome} cadastrado com sucesso"}

      _assinante -> {:error, "Assinante com este número cadastrado"}
    end  
  end

  def buscar_assinante(numero, key \\ :all), do: buscar(numero, key)

  defp buscar(numero, :prepago), do: filtro(assinante_prepago(), numero)
  defp buscar(numero, :pospago), do: filtro(assinante_pospago(), numero)
  defp buscar(numero, :all), do: filtro(assinantes(), numero)
  defp filtro(lista, numero), do: Enum.find(lista, &(&1.numero == numero))

  def assinante_prepago, do: read(:prepago)

  def assinante_pospago, do: read(:pospago)

  def assinantes, do: read(:prepago) ++ read(:pospago)

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
