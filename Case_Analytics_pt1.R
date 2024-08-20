############################################################################################################################################################################################################

# Case QUOD pt1 #

############################################################################################################################################################################################################

# limpando ambiente
rm(list = ls(all.names = TRUE))

## Bibliotecas

if (!require("tidyverse")) {
  install.packages("tidyverse")
}
set.seed(082024) # gerando semente para reprodutibilidade

############################################################################################################################################################################################################

## Gerando banco de dados (Farmácia)
# Variáveis: Data, ID, Produto, Categoria, Quantidade, Preço

dados = data.frame() # df vazio

# Datas
datas = seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by = "day")
datas = format(datas, "%Y-%m-%d") # formato Ano-mes-dia
meses = c("Janeiro", "Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro")


# Definindo produtos
produtos = c("Batom", "Escova de dente", "Pasta de dente", "Esmalte", "Dorflex", "Dipirona", "Rímel", "Fio dental")

# Definindo categorias e criando dicionario
categorias = c("Higiene pessoal","Cosméticos","Saúde")
categorias_dict = c("Batom" = "Cosméticos", "Escova de dente" = "Higiene pessoal", "Pasta de dente" = "Higiene pessoal", "Esmalte" = "Cosméticos",
                    "Dorflex" = "Saúde", "Dipirona" = "Saúde", "Rímel" = "Cosméticos", "Fio dental" = "Higiene pessoal")

# Definindo precos e criando dicionario
valores_dict = c("Batom" = 15.9, "Escova de dente" = 20.73, "Pasta de dente" = 3.1, "Esmalte" = 2.45,
                 "Dorflex" = 6.99, "Dipirona" = 5.25, "Rímel" = 29.9, "Fio dental" = 12.29)

for(i in datas){ # cada dia tera vendas diferentes
  
  n = sample(1:10, 1) # quantidade de vendas no dia i
  ID = as.integer(sample(1:99999, n)) # amostrar ID das vendas do dia
  prod = sample(produtos, size = n, replace = TRUE) # amostrar produtos vendidos no dia
  quant = as.integer(sample(0:10, n, replace = TRUE)) # amostrar quantidade de cada produto vendido (inclui o 0 para considerar "erro" de digitacao)
  if(month(i) == 5){
    quant[categorias_dict[prod] == "Cosméticos"] = quant[categorias_dict[prod] == "Cosméticos"]*2
    # mes de dia das maes (Maio mes 5) as compras foram dobradas
  }
  iteracao = cbind(ID, i, prod, quant) # juntar as variaveis
  dados = rbind(dados, iteracao) # adicionar ao banco de dados
  
}

dados$Categoria = categorias_dict[dados$prod] # criando coluna de Categoria dado produto
dados$Preco = valores_dict[dados$prod] # criando coluna de preco dado produto


names(dados) = c("ID","Data","Produto","Quantidade","Categoria","Preco") # renomeando colunas
dados = dados %>% mutate_at(vars(ID,Quantidade), as.integer)
dados = dados %>% mutate_at(vars(Produto, Categoria), as.factor)
dados$Data = as.character(dados$Data)
# definimos as classes dos dados

## LIMPEZA DOS DADOS

# Checar ID repetido
dados %>% filter(duplicated(ID)) # vamos considerar as vendas duplicadas como erros de digitação e apagaremos todas as aparicões
dados = dados %>% filter(!duplicated(ID))

# Checar vendas com quantidade 0
dados %>% filter(Quantidade == 0) # "falha" ou desistencia de compra 
dados = dados %>% filter(Quantidade != 0) # removendo falhas ou desistencias

str(dados) # Data foi deixada em "chr" para fazer consulta em SQL na parte 2

vendas = dados %>% group_by(Data, Produto) %>% mutate(Quantidade = sum(Quantidade), ID = sum(ID)) %>% ungroup() # se houveram 2+ vendas de um mesmo produto no mesmo dia juntamos as vendas do dia
vendas = vendas %>% filter(!duplicated(ID)) # removemos IDs duplicados

# os dados brutos
write.csv(vendas, file = "data_clean.csv",row.names = FALSE) # defina o diretório antes de salvar usando setwd("caminho/do/arquivo")
 

############################################################################################################################################################################################################


## ANÁLISE DE DADOS


############################################################################################################################################################################################################
# Vendas totais de cada produto
vendas_totais = vendas %>% mutate(total_vendas = Quantidade*Preco) %>%
                           group_by(Produto) %>% summarize(soma_vendas = sum(total_vendas)) %>%
                           ungroup()

# Produto com mais vendas totais
mais_vendas = vendas %>% mutate(total_vendas = Quantidade*Preco) %>%
                        group_by(Produto) %>% summarize(soma_vendas = sum(total_vendas)) %>%
                        ungroup() %>%
                        filter(soma_vendas == max(soma_vendas)) %>%
                        pull(Produto)
mais_vendas # Rimel

vendas = vendas %>% mutate(Dia = day(Data), Mes = month(Data)) # avaliar evoluçao da venda por mes para cada produto em cada mes


# Visualizacao por mes e produto vendas em unidades
for(i in produtos){
  subset = vendas %>% filter(Produto == i)
  grafico = ggplot(subset, aes(x = Dia, y = Quantidade)) +
                  geom_line(colour = "steelblue") + facet_wrap(~Mes, labeller = labeller(Mes = c(`1` = "Janeiro", 
                                                                                                 `2` = "Fevereiro",
                                                                                                 `3` = "Março",
                                                                                                 `4` = "Abril",
                                                                                                 `5` = "Maio",
                                                                                                 `6` = "Junho",
                                                                                                 `7` = "Julho",
                                                                                                 `8` = "Agosto",
                                                                                                 `9` = "Setembro",
                                                                                                 `10` = "Outubro",
                                                                                                 `11` = "Novembro",
                                                                                                 `12` = "Dezembro"))) +
                  lims(y = c(0,max(vendas$Quantidade)+5)) + 
                  theme_bw() + labs(title = paste0("Quantidade de vendas por mês ", i))
  print(grafico)
  
  # vvv    caso queira salvar descomente a linha 130   vvv
  # ggsave(filename = paste0("Vendas ", i , ".png"))
}




# Unidades vendidas por mes
unidades_produto = vendas %>% group_by(Produto, Mes) %>% summarise(n = sum(Quantidade))

ggplot(unidades_produto, aes(x = Mes, y = n, fill = Produto)) +
        geom_bar(stat = "identity", position = "dodge") +
        facet_wrap(~Produto) + 
        scale_x_continuous(labels = meses, breaks = 1:12)+
        theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none") + 
        labs(title = "Unidades vendidas por mês", y = "Quantidade", x = "Mês")

# ggsave(filename = "Unidades.png")


# Receita total por mes por produto
receita_produto =  vendas %>% mutate(total_vendas = Quantidade*Preco) %>% 
                              group_by(Produto, Mes) %>% 
                              summarise(Receita = sum(total_vendas))


ggplot(receita_produto, aes(x = Mes, y = Receita, fill = Produto)) +
        geom_bar(stat = "identity", position = "dodge") +
        facet_wrap(~Produto) + 
        scale_x_continuous(labels = meses, breaks = 1:12)+
        theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "none") + 
        labs(title = "Receita total por mês (em Reais)", y = "Receita", x = "Mês")

# ggsave(filename = "Receita.png")

  
