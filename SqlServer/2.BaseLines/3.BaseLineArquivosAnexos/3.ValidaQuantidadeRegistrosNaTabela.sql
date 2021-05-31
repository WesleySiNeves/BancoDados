

SELECT X.Cliente,
       X.TotalRegistros,
	   X.TotalArquivosBanco
  FROM(
          SELECT DB_NAME() AS Cliente,
                 (
                     SELECT COUNT(1)FROM Sistema.ArquivosAnexos
                 ) AS TotalRegistros,
                 (
                     SELECT COUNT(1)FROM Sistema.ArquivosAnexos WHERE ConteudoEmStorageExterno = 0
                 ) AS TotalArquivosBanco
      )X(Cliente, TotalRegistros,TotalArquivosBanco);