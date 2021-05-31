
/*Parte especifica para limpar configurações com vinculo ao cliente*/
UPDATE C
   SET C.Valor = 'D:\temp_blob_azure\demonstracao\'
  FROM Sistema.Configuracoes AS C
 WHERE
    C.Configuracao = 'CaminhoCacheLocalAzureStorageArquivosAnexos';

UPDATE C
   SET C.Valor = ''
  FROM Sistema.Configuracoes AS C
 WHERE
    C.Configuracao LIKE '%Link%'
    AND LEN(C.Valor) > 0
    AND C.Configuracao NOT LIKE '%Treinamento%';

UPDATE C
   SET C.Valor = 'Demonstração/DF'
  FROM Sistema.Configuracoes AS C
 WHERE
    C.Configuracao = 'SiglaCliente';

UPDATE C
   SET C.Valor = 'Conselho de demonstração'
  FROM Sistema.Configuracoes AS C
 WHERE
    C.Configuracao = 'NomeClienteExtenso';

UPDATE P
   SET P.NomeRazaoSocial = 'Conselho de demonstração'
  FROM Cadastro.Pessoas AS P
 WHERE
    P.IdPessoa = '00000000-0000-0000-0000-000000000001';

UPDATE PJ
   SET PJ.Sigla = 'Demonstração/DF'
  FROM Cadastro.PessoasJuridicas AS PJ
 WHERE
    PJ.IdPessoaJuridica = '00000000-0000-0000-0000-000000000001';


--Senha Padrao

UPDATE Acesso.Usuarios
SET SenhaHash = '$' + '2a$' + '12$Kau5.45v6jpp3DYCpDoUbu0K1pHs0o5gjmi7n.G/u6k6oMzMHHbKq',
    SenhaTipoHash = 'SHA512',
    SenhaAlgoritmo = 'bcrypt';

UPDATE AA
   SET AA.Conteudo = NULL,
       AA.NomeIdentificadorStorageExterno = '',
       AA.UrlStorageExterno = ''
  FROM Sistema.ArquivosAnexos AS AA
 WHERE
    AA.Entidade = 'Cadastro.PessoasImagens'
    AND AA.IdEntidade IN(
                            SELECT PI.IdPessoaImagem
                              FROM Cadastro.PessoasJuridicas AS PJ
                                   JOIN Cadastro.PessoasImagens AS PI ON PI.IdPessoa = PJ.IdPessoa
                             WHERE
                                PJ.IdPessoaJuridica = '00000000-0000-0000-0000-000000000001'
                        );


   ;WITH Strip_Name
        AS
        (
            SELECT P.IdPessoa,
                UPPER(CONCAT(String_AGG(strip.strip_Name, ' '), ' Da Silva')) stripName
            FROM Cadastro.Pessoas AS P
                CROSS APPLY(
                                SELECT value AS strip_Name,
                                        RN = ROW_NUMBER() OVER (ORDER BY(SELECT NULL))
                                    FROM STRING_SPLIT(REPLACE(REPLACE(REPLACE(P.NomeRazaoSocial, 'DAS', ' '), 'DOS', ' '), 'DE', ' '), ' ')
                            )strip
            WHERE
                P.TipoPessoaFisica = 1
                --	AND P.IdPessoa ='915BD6E9-2210-4579-86D8-002C06661090'
                AND P.IdPessoa <> '00000000-1111-2222-3333-000000000002'
                AND strip.RN <= 2
            GROUP BY
                P.IdPessoa
        )
    UPDATE P
    SET P.NomeRazaoSocial = strip.stripName
    FROM Cadastro.Pessoas AS P
        JOIN Strip_Name strip ON P.IdPessoa = strip.IdPessoa;                        