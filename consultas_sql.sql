SELECT Produto, Categoria, SUM(Quantidade*Preco) AS Total_Vendas FROM dados
                              GROUP BY Produto
                              ORDER BY Total_Vendas DESC
--selecionei as variaveis que eu queria que aparecessem na consulta, falei a tabela de onde haviam os dados e agrupei por produto pois era o que era pedido, ordenei em ordem decrescente a coluna Total_Vendas
-- 
SELECT Produto, Data, SUM(Quantidade*Preco) AS Total_Vendas FROM dados
          WHERE Data BETWEEN '2023-06-01' AND '2023-06-30'
          GROUP BY Produto 
          ORDER BY Total_Vendas ASC
          LIMIT 3
--selecionei as variaveis que pedia, criei a variavel total_vendas, disse para puxar do df dados, selecionei o intervalo de junho, agrupei por produto, ordenei por vendas de forma crescente e peguei os 3 primeiros que seria os 3 menores numeros de vendas 
--
SELECT Produto, SUM(Quantidade) AS Unidades FROM dados
          WHERE Data BETWEEN '2023-06-01' AND '2023-06-30'
          GROUP BY Produto 
          ORDER BY Unidades ASC
          LIMIT 3
--filtrei os produtos que venderam menos unidades no mes de junho
