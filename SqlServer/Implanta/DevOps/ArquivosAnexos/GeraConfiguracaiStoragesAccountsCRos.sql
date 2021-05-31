
DECLARE @dataStart TIME  = '12:45:00'
DECLARE @increment TIME ='0:15:00'
--5:28 PM


;WITH Dados
    AS
    (

	    
        SELECT name, Rn = 15 *( ROW_NUMBER() OVER(ORDER BY name)),
		@dataStart AS Start,
		TimeCorreto =DATEADD(MINUTE,15,@dataStart)
          FROM sys.databases
         WHERE
            (
                (name LIKE '%implanta.net.br'
                AND name LIKE '%cro%'
                AND NOT(name = 'cro-sp.implanta.net.br')
				)
				OR name = 'cfo-br.implanta.net.br'
            )
        
    )
SELECT R.name,
R.Rn,
       Scheldules = CONCAT('PRD-DataBaseBackUp-', UPPER(REPLACE(R.name, '.implanta.net.br', ''))),
	   Description = CONCAT('Geração do backup do banco ',R.name),
	   Data = '06/05/2021',
	  -- X = TimeCorreto,
	--   Y = DATEADD(MINUTE,R.Rn,TimeCorreto),
	   TimeCorreto = CONCAT(LEFT(LAG(DATEADD(MINUTE,R.Rn,TimeCorreto),1,R.TimeCorreto) OVER(ORDER BY R.Rn),5),' PM'),
	    ExternalClientName =LOWER(REPLACE(R.name, '.implanta.net.br', '')),
	   StorageAccountName ='rgbkpextcrocfo',
	   StorageAccountKey ='Gu+hpKBJFRV81DkJK/8zcKrfVflftiUgzct9e+zJ+/i+9DMpCZKY9KpNMAU3qzKqcIDwKDS0n8tvTcDsB3zA6Q=='
	  
  FROM Dados R;


