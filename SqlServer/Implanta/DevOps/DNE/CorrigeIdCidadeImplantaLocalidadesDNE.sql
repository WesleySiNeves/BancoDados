DECLARE @ROLLBACK BIT = 1;

SET XACT_ABORT ON;

BEGIN TRANSACTION SCHEDULE;

BEGIN TRY
    IF(OBJECT_ID('TEMPDB..#PossiveisInconsistencias') IS NOT NULL)
        DROP TABLE #PossiveisInconsistencias;

    CREATE TABLE #PossiveisInconsistencias
    (
        [IdLocalidade]       UNIQUEIDENTIFIER,
        [Numero]             INT,
        [SiglaUF]            VARCHAR(2),
        [Nome]               VARCHAR(200),
        [Tipo]               VARCHAR(1),
        [NumeroSubordinacao] INT,
        [CEP]                VARCHAR(8),
        [CodigoIBGE]         INT,
        [IdCidadeImplanta]   UNIQUEIDENTIFIER,
        IdCidadeCorreta      UNIQUEIDENTIFIER,
        CodigoIBGECorreto    INT
    );

    INSERT INTO #PossiveisInconsistencias(
                                             IdLocalidade,
                                             Numero,
                                             SiglaUF,
                                             Nome,
                                             Tipo,
                                             NumeroSubordinacao,
                                             CEP,
                                             CodigoIBGE,
                                             IdCidadeImplanta
                                         )
    SELECT L.IdLocalidade,
           L.Numero,
           L.SiglaUF,
           L.Nome,
           L.Tipo,
           L.NumeroSubordinacao,
           L.CEP,
           L.CodigoIBGE,
           L.IdCidadeImplanta
      FROM DNE.Localidades AS L
           JOIN Corporativo.Cidades AS C ON L.IdCidadeImplanta = C.IdCidade
     WHERE
        L.Nome <> C.Nome
     ORDER BY
        C.CodigoIBGE,
        L.NumeroSubordinacao;

    INSERT INTO #PossiveisInconsistencias(
                                             IdLocalidade,
                                             Numero,
                                             SiglaUF,
                                             Nome,
                                             Tipo,
                                             NumeroSubordinacao,
                                             CEP,
                                             CodigoIBGE,
                                             IdCidadeImplanta
                                         )
    SELECT L.IdLocalidade,
           L.Numero,
           L.SiglaUF,
           L.Nome,
           L.Tipo,
           L.NumeroSubordinacao,
           L.CEP,
           L.CodigoIBGE,
           L.IdCidadeImplanta
      FROM DNE.Localidades AS L
     WHERE
        L.IdCidadeImplanta IS NULL
        AND L.Tipo = 'M';

    UPDATE Municipio
       SET Municipio.CodigoIBGECorreto = Municipio.CodigoIBGE,
           Municipio.IdCidadeCorreta = CidadeCorreta.IdCidade
      FROM #PossiveisInconsistencias AS Municipio
           CROSS APPLY(
                          SELECT C.IdCidade,
                                 C.Nome,
                                 C.CodigoIBGE
                            FROM Corporativo.Cidades AS C
                                 JOIN Corporativo.Estados AS E ON E.IdEstado = C.IdEstado
                           WHERE
                              C.Nome = Municipio.Nome
                              AND E.SiglaUF = Municipio.SiglaUF
                      )CidadeCorreta
     WHERE
        CidadeCorreta.IdCidade <> Municipio.IdCidadeImplanta
        AND Municipio.NumeroSubordinacao IS NULL;

    UPDATE Distrito
       SET Distrito.IdCidadeCorreta = Municipio.IdCidadeImplanta
      FROM #PossiveisInconsistencias AS Distrito
           CROSS APPLY(
                          SELECT L.Numero,
                                 L.CodigoIBGE,
                                 L.IdCidadeImplanta,
                                 L.Nome
                            FROM DNE.Localidades AS L
                           WHERE
                              L.Numero = Distrito.NumeroSubordinacao
                              AND L.Tipo = 'M'
                      )Municipio
     WHERE
        Distrito.Tipo = 'D'
        AND Municipio.IdCidadeImplanta <> Distrito.IdCidadeImplanta;

    UPDATE PI
       SET PI.IdCidadeCorreta = Cidade.IdCidade,
           PI.CodigoIBGECorreto = PI.CodigoIBGE
      FROM #PossiveisInconsistencias AS PI
           CROSS APPLY(
                          SELECT C.IdCidade
                            FROM Corporativo.Cidades AS C
                                 JOIN Corporativo.Estados AS E ON E.IdEstado = C.IdEstado
                           WHERE
                              C.Nome = PI.Nome
                              AND E.SiglaUF = PI.SiglaUF
                      )Cidade
     WHERE
        PI.IdCidadeImplanta IS NULL;

    SELECT * FROM #PossiveisInconsistencias AS PI;

    SELECT *
      FROM Corporativo.Cidades AS C
     WHERE
        C.IdCidade = 'D4239E7D-B7B2-474A-80E1-B9EFA84010CF';

    SELECT PI.IdLocalidade,
           PI.Numero,
           PI.SiglaUF,
           PI.Nome,
           PI.Tipo,
           PI.NumeroSubordinacao,
           PI.CEP,
           PI.CodigoIBGE,
           PI.IdCidadeImplanta,
           PI.IdCidadeCorreta,
           'Errado=>>',
           VinculoErrado.SiglaUF,
           VinculoErrado.Nome,
           VinculoErrado.CodigoIBGE,
           'Correto==>',
           CidadeCorreta.SiglaUF,
           CidadeCorreta.Nome,
           CidadeCorreta.CodigoIBGE
      FROM #PossiveisInconsistencias AS PI
           OUTER APPLY(
                          SELECT E.SiglaUF,
                                 C.IdCidade,
                                 C.Nome,
                                 C.CodigoIBGE
                            FROM Corporativo.Cidades AS C
                                 JOIN Corporativo.Estados AS E ON E.IdEstado = C.IdEstado
                           WHERE
                              C.IdCidade = PI.IdCidadeImplanta
                      )VinculoErrado
           CROSS APPLY(
                          SELECT E.SiglaUF,
                                 C.IdCidade,
                                 C.Nome,
                                 C.CodigoIBGE
                            FROM Corporativo.Cidades AS C
                                 JOIN Corporativo.Estados AS E ON E.IdEstado = C.IdEstado
                           WHERE
                              C.IdCidade = PI.IdCidadeCorreta
                      )CidadeCorreta;

    UPDATE target
       SET target.IdCidadeImplanta = PI.IdCidadeCorreta
      FROM DNE.Localidades target
           JOIN #PossiveisInconsistencias AS PI ON PI.IdLocalidade = target.IdLocalidade
     WHERE
        PI.IdCidadeCorreta IS NOT NULL;

    /*End region */
    IF @ROLLBACK = 0
        BEGIN
            COMMIT TRANSACTION SCHEDULE;
        END;
    ELSE
        BEGIN
            ROLLBACK TRANSACTION SCHEDULE;
        END;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION SCHEDULE;

    DECLARE @ErrorNumber INT = ERROR_NUMBER();
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(MAX));
    PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(MAX));
    PRINT '@ErrorMessage: ' + CAST(@ErrorMessage AS VARCHAR(MAX));
    PRINT '@ErrorSeverity: ' + CAST(@ErrorLine AS VARCHAR(MAX));
    PRINT '@ErrorState: ' + CAST(@ErrorLine AS VARCHAR(MAX));

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

    PRINT 'Error detected, all changes reversed.';
END CATCH;