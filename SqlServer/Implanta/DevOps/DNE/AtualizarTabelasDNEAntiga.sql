-- EXEC [DNE].[AtualizarTabelasDNE] @aceite =1




CREATE OR ALTER PROCEDURE [DNE].[AtualizarTabelasDNE]
    @aceite AS BIT = NULL
AS
    BEGIN
        IF ISNULL(@aceite, 0) = 0
            BEGIN
                PRINT '===================================================';
                PRINT '============= IMPLANTA INFORMÃTICA ================';
                PRINT '===================================================';
                PRINT '=                                                 =';
                PRINT '= Antes de executar a Stored Prodedure deve-se    =';
                PRINT '= primeiro ter consiencia que ela irÃ¡ apagar os   =';
                PRINT '= dados das tabelas do schema DNE e repopoula-los =';
                PRINT '= com base no bano de dados "DNE"                 =';
                PRINT '=                                                 =';
                PRINT '= Para a SP funcionar, deve existir o banco DNE   =';
                PRINT '= no servidor, com as tabelas padrÃµes dos Correios =';
                PRINT '=                                                 =';
                PRINT '===================================================';
                PRINT '=                                                 =';
                PRINT '= Como forma de garantir que vocÃª estÃ¡ ciÃªnte do  =';
                PRINT '= compormento desta SP. Se ainda deseja executar, =';
                PRINT '= execute novamente esta SP, porÃ©m agora passe o  =';
                PRINT '= parÃ¢metro de aceite.  Veja o exemplo abaixo:    =';
                PRINT '=                                                 =';
                PRINT '= exec [DNE].[AtualizarTabelasDNE] @aceite=1      =';
                PRINT '===================================================';

                RETURN;
            END;

        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + ' Inicia a transaÃ§Ã£o...';

        BEGIN TRANSACTION;

        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + ' Limpa os dados atuais das tabelas DNE, deixando apenas os dados customizados pelo usuario...';

        DELETE FROM [DNE].[LogradourosVariacoes] WHERE Implanta = 0;

        DELETE TARGET
          FROM DNE.LogradourosSeccionamentos TARGET
               JOIN [DNE].[Logradouros] SOURCE ON TARGET.IdLogradouro = SOURCE.IdLogradouro
                                                  AND SOURCE.Implanta = 0;


		DELETE DNE.CaixasPostaisComunitarias	WHERE Implanta = 0

		DELETE DNE.BairrosFaixas WHERE Implanta = 0

        DELETE FROM [DNE].[Logradouros] WHERE Implanta = 0;

        DELETE FROM [DNE].[BairrosVariacoes] WHERE Implanta = 0;

        DELETE FROM [DNE].[BairrosDNE]
         WHERE
            Implanta = 0
            AND IdBairroDNE NOT IN(
                                      SELECT l.IdBairroInicial FROM DNE.Logradouros l WHERE l.Implanta = 1
                                  );

        DELETE FROM [DNE].[LocalidadesVariacoes] WHERE Implanta = 0;

        DELETE FROM [DNE].[LocalidadesFaixas] WHERE Implanta = 0;

        DELETE FROM [DNE].[Localidades]
         WHERE
            Implanta = 0
            AND IdLocalidade NOT IN(
                                       SELECT l.IdLocalidade FROM DNE.Logradouros l WHERE l.Implanta = 1
                                   );



        DELETE FROM [DNE].[UFFaixas] WHERE Implanta = 0;

        DECLARE @BAI_NU INT;
        DECLARE @LOC_NU INT;
        DECLARE @LOC_NO NVARCHAR(250);
        DECLARE @CEP NVARCHAR(8);
        DECLARE @LOC_CEP_INI NVARCHAR(8);
        DECLARE @LOC_CEP_FIM NVARCHAR(8);
        DECLARE @BAI_NO NVARCHAR(100);
        DECLARE @UFE_SG NVARCHAR(2);
        DECLARE @BAI_NO_ABREV NVARCHAR(100);
        DECLARE @LOC_IN_SIT NVARCHAR(1);
        DECLARE @LOC_IN_TIPO_LOC NVARCHAR(1);
        DECLARE @LOC_NU_SUB INT;
        DECLARE @LOC_NO_ABREV NVARCHAR(100);
        DECLARE @MUN_NU INT;
        DECLARE @IdCidade UNIQUEIDENTIFIER = NULL;
        DECLARE @IdBairro UNIQUEIDENTIFIER = NULL;

        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + ' Limpa os dados atuais da tabela [Corporativo].[Bairros], deixando apenas os bairros utilizados, por questÃµes de FK...';

        DECLARE CURSOR_BAIRROS CURSOR FOR
        SELECT IdBairro FROM [Corporativo].[Bairros];

        OPEN CURSOR_BAIRROS;

        FETCH NEXT FROM CURSOR_BAIRROS
         INTO @IdBairro;

        WHILE @@FETCH_STATUS = 0
            BEGIN
                BEGIN TRY
                    --aqui tentamos excluir o bairro na tabela da impanta, se der erro, Ã© porque o bairro
                    --jÃ¡ esta associado a um endereÃ§o
                    PRINT @IdBairro;

                    DELETE FROM Corporativo.Bairros WHERE IdBairro = @IdBairro;
                END TRY
                BEGIN CATCH
                --PRINT ERROR_MESSAGE()
                END CATCH;

                FETCH NEXT FROM CURSOR_BAIRROS
                 INTO @IdBairro;
            END;

        CLOSE CURSOR_BAIRROS;
        DEALLOCATE CURSOR_BAIRROS;

        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + ' Carrega as tabelas do schema DNE...';
        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + '	-> Insere os registros na tabela [DNE].[Localidades]';

        DECLARE CURSOR_LOG_LOCALIDADE CURSOR FOR
        SELECT LOC_NU,
               UFE_SG,
               LOC_NO,
               CEP,
               LOC_IN_SIT,
               LOC_IN_TIPO_LOC,
               LOC_NU_SUB,
               LOC_NO_ABREV,
               MUN_NU
          FROM [dbo].[LOG_LOCALIDADE];

        OPEN CURSOR_LOG_LOCALIDADE;

        FETCH NEXT FROM CURSOR_LOG_LOCALIDADE
         INTO @LOC_NU,
              @UFE_SG,
              @LOC_NO,
              @CEP,
              @LOC_IN_SIT,
              @LOC_IN_TIPO_LOC,
              @LOC_NU_SUB,
              @LOC_NO_ABREV,
              @MUN_NU;

        WHILE @@FETCH_STATUS = 0
            BEGIN
                SELECT @IdCidade = IdCidade
                  FROM [Corporativo].[Cidades] C
                 WHERE
                    C.CodigoIBGE = @MUN_NU;

                DECLARE @IdLocalidade UNIQUEIDENTIFIER = '00000000-0000-0000-0000-' + REPLACE(STR(@LOC_NU, 12), SPACE(1), '0');
                DECLARE @IdLocalidadeExistente UNIQUEIDENTIFIER = NULL;

                SELECT @IdLocalidadeExistente = IdLocalidade
                  FROM DNE.Localidades l
                 WHERE
                    l.IdLocalidade = @IdLocalidade;

                IF(@IdLocalidadeExistente IS NULL)
                    BEGIN
                        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + '[DNE].[Localidades]	->' + @LOC_NO;

                        INSERT INTO DNE.Localidades(
                                                       IdLocalidade,
                                                       Numero,
                                                       SiglaUF,
                                                       Nome,
                                                       CEP,
                                                       Situacao,
                                                       Tipo,
                                                       NumeroSubordinacao,
                                                       Abreviatura,
                                                       CodigoIBGE,
                                                       DataCadastro,
                                                       Implanta,
                                                       IdCidadeImplanta
                                                   )
                        VALUES(   @IdLocalidade,    -- IdLocalidade - uniqueidentifier
                                  @LOC_NU,          -- Numero - int
                                  @UFE_SG,          -- SiglaUF - varchar(2)
                                  @LOC_NO,          -- Nome - varchar(200)
                                  @CEP,             -- CEP - varchar(8)
                                  @LOC_IN_SIT,      -- Situacao - varchar(1)
                                  @LOC_IN_TIPO_LOC, -- Tipo - varchar(1)
                                  @LOC_NU_SUB,      -- NumeroSubordinacao - int
                                  @LOC_NO_ABREV,    -- Abreviatura - varchar(50)
                                  @MUN_NU,          -- CodigoIBGE - int
                                  GETDATE(),        -- DataCadastro - datetime
                                  0,                -- Implanta - bit
                                  @IdCidade         -- IdCidadeImplanta - uniqueidentifier
                              );
                    END;
                ELSE
                    BEGIN
                        UPDATE DNE.Localidades
                           SET Numero = @LOC_NU,                 -- Numero - int
                               SiglaUF = @UFE_SG,                -- SiglaUF - varchar(2)
                               Nome = @LOC_NO,                   -- Nome - varchar(200)
                               CEP = @CEP,                       -- CEP - varchar(8)
                               Situacao = @LOC_IN_SIT,           -- Situacao - varchar(1)
                               Tipo = @LOC_IN_TIPO_LOC,          -- Tipo - varchar(1)
                               NumeroSubordinacao = @LOC_NU_SUB, -- NumeroSubordinacao - int
                               Abreviatura = @LOC_NO_ABREV,      -- Abreviatura - varchar(50)
                               CodigoIBGE = @MUN_NU,
                               IdCidadeImplanta = @IdCidade
                         WHERE
                            IdLocalidade = @IdLocalidadeExistente;
                    END;

                FETCH NEXT FROM CURSOR_LOG_LOCALIDADE
                 INTO @LOC_NU,
                      @UFE_SG,
                      @LOC_NO,
                      @CEP,
                      @LOC_IN_SIT,
                      @LOC_IN_TIPO_LOC,
                      @LOC_NU_SUB,
                      @LOC_NO_ABREV,
                      @MUN_NU;
            END;

        CLOSE CURSOR_LOG_LOCALIDADE;
        DEALLOCATE CURSOR_LOG_LOCALIDADE;

        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + '	-> Insere os registros na tabela [DNE].[UFFaixas]';

        INSERT INTO DNE.UFFaixas(
                                    IdUFFaixa,
                                    SiglaUF,
                                    CEPInicial,
                                    CEPFinal,
                                    DataCadastro,
                                    Implanta
                                )
        SELECT NEWID() AS IdUFFaixa,
               [UFE_SG],
               [UFE_CEP_INI],
               [UFE_CEP_FIM],
               GETDATE(),
               0
          FROM [dbo].[LOG_FAIXA_UF];

        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + '	-> Insere os registros na tabela [DNE].[LocalidadesFaixas]';

        INSERT INTO DNE.LocalidadesFaixas(
                                             IdLocalidadeFaixa,
                                             IdLocalidade,
                                             CEPInicial,
                                             CEPFinal,
                                             DataCadastro,
                                             Implanta
                                         )
        SELECT NEWID() AS IdLocalidadeFaixa,
               '00000000-0000-0000-0000-' + REPLACE(STR(LOC_NU, 12), SPACE(1), '0') AS IdLocalidade,
               [LOC_CEP_INI],
               [LOC_CEP_FIM],
               GETDATE() AS DataCadastro,
               0 AS Implanta
          FROM [dbo].[LOG_FAIXA_LOCALIDADE];

        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + '	-> Insere os registros na tabela [DNE].[LocalidadesVariacoes]';

        INSERT INTO DNE.LocalidadesVariacoes
        SELECT NEWID() AS IdLocalidadeVariacao,
               '00000000-0000-0000-0000-' + REPLACE(STR(LOC_NU, 12), SPACE(1), '0') AS IdLocalidade,
               STR(VAL_NU) AS Ordem,
               VAL_TX AS Nome,
               GETDATE() AS DataCadastro,
               0 AS Implanta
          FROM [dbo].[LOG_VAR_LOC];

        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + '	-> Insere os registros na tabela [Corporativo].[Bairros] e [DNE].[BairrosDNE]';

        DECLARE CURSOR_BAIRROS_DNE CURSOR FOR
        SELECT BAI_NU,
               UFE_SG,
               LOC_NU,
               BAI_NO,
               BAI_NO_ABREV
          FROM [dbo].[LOG_BAIRRO];

        OPEN CURSOR_BAIRROS_DNE;

        FETCH NEXT FROM CURSOR_BAIRROS_DNE
         INTO @BAI_NU,
              @UFE_SG,
              @LOC_NU,
              @BAI_NO,
              @BAI_NO_ABREV;

        WHILE @@FETCH_STATUS = 0
            BEGIN
                --Verifica se na tabela da implanta, jÃ¡ existe este bairro
                DECLARE @IdBairroExistente UNIQUEIDENTIFIER = NULL;

                SELECT @MUN_NU = MUN_NU
                  FROM [dbo].[LOG_LOCALIDADE] L
                 WHERE
                    L.LOC_NU = @LOC_NU;

                IF @MUN_NU IS NOT NULL
                    BEGIN
                        SELECT @IdCidade = IdCidade
                          FROM [Corporativo].[Cidades] C
                         WHERE
                            C.CodigoIBGE = @MUN_NU;

                        IF @IdCidade IS NOT NULL
                            BEGIN
                                SELECT @IdBairroExistente = IdBairro
                                  FROM Corporativo.Bairros B
                                 WHERE
                                    B.IdCidade = @IdCidade
                                    AND B.Nome = @BAI_NO;

                                IF @IdBairroExistente IS NULL
                                    BEGIN
                                        SET @IdBairroExistente = '00000000-0000-0000-0000-' + REPLACE(STR(@BAI_NU, 12), SPACE(1), '0');

                                        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + '[Corporativo].[Bairros]	->' + @BAI_NO;

                                        INSERT INTO Corporativo.Bairros(
                                                                           IdBairro,
                                                                           IdCidade,
                                                                           Nome,
                                                                           Ativo
                                                                       )
                                        VALUES(   @IdBairroExistente, -- IdBairro - uniqueidentifier
                                                  @IdCidade,          -- IdCidade - uniqueidentifier
                                                  @BAI_NO,            -- Nome - varchar(100)
                                                  1                   -- Ativo - bit
                                              );
                                    END;
                            END;
                    END;

                DECLARE @IdBairroDNE UNIQUEIDENTIFIER = '00000000-0000-0000-0000-' + REPLACE(STR(@BAI_NU, 12), SPACE(1), '0');
                DECLARE @IdBairroDNEExistente UNIQUEIDENTIFIER = NULL;

                SELECT @IdBairroDNEExistente = IdBairroDNE
                  FROM DNE.BairrosDNE
                 WHERE
                    IdBairroDNE = @IdBairroDNE;

                IF(@IdBairroDNEExistente IS NULL)
                    BEGIN
                        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + '[DNE].[BairrosDNE]	->' + @BAI_NO;

                        INSERT INTO DNE.BairrosDNE(
                                                      IdBairroDNE,
                                                      IdLocalidade,
                                                      Numero,
                                                      SiglaUF,
                                                      Nome,
                                                      Abreviatura,
                                                      DataCadastro,
                                                      Implanta,
                                                      IdBairroImplanta
                                                  )
                        VALUES(   @IdBairroDNE,
                                  '00000000-0000-0000-0000-' + REPLACE(STR(@LOC_NU, 12), SPACE(1), '0'), -- IdLocalidade - uniqueidentifier
                                  @BAI_NU,                                                               -- Numero - int
                                  @UFE_SG,                                                               -- SiglaUF - varchar(2)
                                  @BAI_NO,                                                               -- Nome - varchar(200)
                                  @BAI_NO_ABREV,                                                         -- Abreviatura - varchar(50)
                                  GETDATE(),                                                             -- DataCadastro - datetime
                                  0,                                                                     -- Implanta - bit
                                  @IdBairroExistente                                                     -- IdBairroImplanta - uniqueidentifier
                              );
                    END;
                ELSE
                    BEGIN
                        UPDATE DNE.BairrosDNE
                           SET IdLocalidade = '00000000-0000-0000-0000-' + REPLACE(STR(@LOC_NU, 12), SPACE(1), '0'), -- IdLocalidade - uniqueidentifier
                               Numero = @BAI_NU,                                                                     -- Numero - int
                               SiglaUF = @UFE_SG,                                                                    -- SiglaUF - varchar(2)
                               Nome = @BAI_NO,                                                                       -- Nome - varchar(200)
                               Abreviatura = @BAI_NO_ABREV                                                           -- Abreviatura - varchar(50)
                         WHERE
                            IdBairroDNE = @IdBairroDNEExistente;
                    END;

                FETCH NEXT FROM CURSOR_BAIRROS_DNE
                 INTO @BAI_NU,
                      @UFE_SG,
                      @LOC_NU,
                      @BAI_NO,
                      @BAI_NO_ABREV;
            END;

        CLOSE CURSOR_BAIRROS_DNE;
        DEALLOCATE CURSOR_BAIRROS_DNE;

        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + '	-> Insere os registros na tabela [DNE].[BairrosVariacoes]';

        INSERT INTO [DNE].[BairrosVariacoes]
        SELECT NEWID() AS IdBairroVariacao,
               '00000000-0000-0000-0000-' + REPLACE(STR(BAI_NU, 12), SPACE(1), '0') AS IdBairro,
               STR(VDB_NU) AS Ordem,
               VDB_TX AS Nome,
               GETDATE() AS DataCadastro,
               0 AS Implanta
          FROM [dbo].[LOG_VAR_BAI];

        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + '	-> Insere os registros na tabela [DNE].[Logradouros]';

        INSERT INTO [DNE].[Logradouros]
        SELECT '00000000-0000-0000-0000-' + REPLACE(STR(LOG_NU, 12), SPACE(1), '0') AS IdLogradouro,
               '00000000-0000-0000-0000-' + REPLACE(STR(LOC_NU, 12), SPACE(1), '0') AS IdLocalidade,
               LOG_NU AS Numero,
               UFE_SG AS SiglaUF,
               '00000000-0000-0000-0000-' + REPLACE(STR(BAI_NU_INI, 12), SPACE(1), '0') AS IdBairroInicial,
               CASE WHEN BAI_NU_FIM IS NULL THEN NULL ELSE ('00000000-0000-0000-0000-' + REPLACE(STR(BAI_NU_FIM, 12), SPACE(1), '0') + '')END AS IdBairroFinal,
               LOG_NO AS Nome,
               LOG_COMPLEMENTO AS Complemento,
               CEP AS CEP,
               TLO_TX AS Tipo,
               LOG_STA_TLO AS UtilizaTipo,
               LOG_NO_ABREV AS Abreviatura,
               GETDATE() AS dataCadastro,
               0 AS Implanta,
               NULL AS NomeUsuarioChancela,
               NULL AS DataChancela,
               NULL AS JustificativaChancela
          FROM [dbo].[LOG_LOGRADOURO];

        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + '	-> Insere os registros na tabela [DNE].[LogradourosVariacoes]';

        INSERT INTO [DNE].[LogradourosVariacoes]
        SELECT NEWID() AS IdLogradouroVariacao,
               '00000000-0000-0000-0000-' + REPLACE(STR(LOG_NU, 12), SPACE(1), '0') AS IdLogradouro,
               VLO_NU AS Ordem,
               TLO_TX AS Tipo,
               VLO_TX AS Nome,
               GETDATE() AS dataCadastro,
               0 AS Implanta
          FROM [dbo].[LOG_VAR_LOG];

        PRINT CONVERT(NVARCHAR(50), GETDATE(), 120) + ' Comita a transaÃ§Ã£o';

        COMMIT TRANSACTION;
    END;
GO