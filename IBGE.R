#Instalando as bibliotecas

install.packages("sidrar") #Biblioteca do IBGE
install.packages("dplyr")  #Biblioteca para manipulação de datasets
install.packages("lubridate") #Biblioteca para trabalhar com datas
install.packages("ggplot2") #Bibliotecas para gráfico

#verificando as bibliotecas
library(sidrar)
library(dplyr)
library(lubridate)
library(ggplot2)



#Coletando os dados do IBGE sobre Força de Trabalho
raw_ocupado_e_desocupado <- sidrar::get_sidra(api = "/t/6318/n1/all/v/1641/p/all/c629/all")
#print(raw_ocupado_e_desocupado)

#Selecionando apenas 3 colunas dos dados do IBGE
ocupado_e_desocupado <- raw_ocupado_e_desocupado |>
  dplyr::select(
    "date"     = 'Trimestre Móvel (Código)',
    "variable" = 'Condição em relação à força de trabalho e condição de ocupação',
    "value"    = 'Valor'
  ) |>
  dplyr::as_tibble()
#print(ocupado_e_desocupado)

#Realizando modificações no nome das colunas e na ordem de grandeza dos valores
ocupado_e_desocupado <- ocupado_e_desocupado |>
  dplyr::mutate(
    date = lubridate::ym(date),
    variable = dplyr::recode(
      variable,
      "Total"                          = "População Total (PIA)",
      "Força de trabalho"              = "Força de Trabalho (PEA)",
      "Força de trabalho - ocupada"    = "Ocupados",
      "Força de trabalho - desocupada" = "Desocupados",
      "Fora da força de trabalho"       = "Fora da Força (PNEA)"
    ),
    value = value / 1000 #Convertendo patra milhões de pessoas
  )
#print(ocupado_e_desocupado)

#Mantendo os dados de 2020 em diante
ocupado_e_desocupado <- ocupado_e_desocupado |>
  dplyr::filter(date > "2020-01-01")

#Calculando a média anual (group_by) de cada valor
ocupado_e_desocupado <- ocupado_e_desocupado |>
  dplyr::group_by(year=lubridate::year(date), variable) |>
  dplyr::summarise(mean = mean(value))

print(ocupado_e_desocupado)
