CREATE TABLE [dbo].[QAGATE_1_KeyenceData] (
    [Id_Keyence]      INT          IDENTITY (1, 1) NOT NULL,
    [Current_OF]      VARCHAR (10) NOT NULL,
    [Reference]       VARCHAR (15) NOT NULL,
    [Double_Taillage] BIT          DEFAULT (NULL) NULL,
    [Coup_Denture_1]  BIT          DEFAULT (NULL) NULL,
    [Coup_Denture_2]  BIT          DEFAULT (NULL) NULL,
    [Chanfrein_1]     BIT          DEFAULT (NULL) NULL,
    [Chanfrein_2]     BIT          DEFAULT (NULL) NULL,
    [Chanfrein_3]     BIT          DEFAULT (NULL) NULL,
    [Chanfrein_4]     BIT          DEFAULT (NULL) NULL,
    [Heure_Reseau]    DATETIME     DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id_Keyence] ASC)
);


GO

CREATE TRIGGER [dbo].[QAGATE_1_TriggerKeyence] 
	ON [dbo].[QAGATE_1_KeyenceData]
	FOR INSERT
	AS
	BEGIN
		CREATE TABLE #File																			-- Création d'une table permettant de contenir le nom des fichiers .txt
        (
			FileName    SYSNAME,
			Depth       TINYINT,
			IsFile      TINYINT
        )

		DECLARE	@Reference VARCHAR(15)																-- Référence pièce
		DECLARE @Path VARCHAR(100)																	-- Chemin du dossier des données Keyence
		DECLARE @Ref VARCHAR(2)																		-- Numéro de dossier, dépend de la référénce pièce
		DECLARE @Var VARCHAR(102)																	-- Chemin du dossier + numéro du dossier
		DECLARE @CSV VARCHAR(20)																	-- Nom du fichier .txt
		DECLARE @PathCSV VARCHAR(122)																-- Chemin complet du dossier + nom du fichier .txt
		DECLARE @SQL VARCHAR(MAX)																	-- Contient la query de récupération des données

		SET @Path = '\\SERV14\Public\zzz_Exchange\JPIJER\Fichiers Charly\cv-x\result\SD1_00'		-- Chemin du dossier des données Keyence (sans le numéro dossier)
		SET @Reference = (SELECT TOP(1) Reference FROM QAGATE_1_KeyenceData ORDER BY Id_Keyence DESC)		
																									-- Récupération de la référence de la dernière pièce contrôlée par Keyence

		IF(@Reference = '490035-2000')																-- Table de vérité
			SET @Ref = '6'
		ELSE IF(@Reference = '490035-2100')
			SET @Ref = '7'
		ELSE IF(@Reference = '490035-3200')
			SET @Ref = '8'
		ELSE IF(@Reference = '490035-3300')
			SET @Ref = '9'

		SET @Var = @Path + @Ref																		-- Chemin du dossier des données Keyence + numéro du dossier

		INSERT INTO #File (FileName, Depth, IsFile)													-- Insertion dans la table #File de tout le noms de fichier présent dans le dossier des données Keyence

		EXEC xp_DirTree @Var,1,1																	-- Commande permettant d'obtenir les noms de fichier dans le dossier des données Keyence

		SET @CSV = (SELECT TOP (1) FileName FROM #File WHERE IsFile = 1 ORDER BY FileName DESC)		-- Selection du dernier fichier de données créé


		DROP TABLE #File																			-- Suppression de la table temporaire #File

		SET @PathCSV = @Var + '\' + @CSV															-- Concaténation du chemin du dossier des données Keyence (avec numéro) + nom du dernier fichier de données créé

		CREATE TABLE #tempDATA (																	-- Création d'une table respectant l'ordre d'arriver des données
			[Id_Keyence]      INT IDENTITY (1, 1) NOT NULL,
			[Double_Taillage] BIT,
			[Coup_Denture_1]  BIT,
			[Coup_Denture_2]  BIT,
			[Chanfrein_1]     BIT,
			[Chanfrein_2]     BIT,
			[Chanfrein_3]     BIT,
			[Chanfrein_4]     BIT
		);
		
		SET @SQL = 'BULK INSERT #tempDATA FROM ''' + @PathCSV + ''' WITH (FIRSTROW = 1,FIELDTERMINATOR = '','',ROWTERMINATOR = ''\r'')'

		EXEC (@SQL)																					-- Excecution de la query permettant la récupération des données Keyence du dernier fichier créé

		UPDATE QAGATE_1_KeyenceData SET Double_Taillage = (SELECT TOP(1) Double_Taillage FROM #tempDATA ORDER BY Id_Keyence DESC) WHERE Id_Keyence = (SELECT TOP(1) Id_Keyence FROM QAGATE_1_KeyenceData ORDER BY Id_Keyence DESC)
		UPDATE QAGATE_1_KeyenceData SET Coup_Denture_1 = (SELECT TOP(1) Coup_Denture_1 FROM #tempDATA ORDER BY Id_Keyence DESC) WHERE Id_Keyence = (SELECT TOP(1) Id_Keyence FROM QAGATE_1_KeyenceData ORDER BY Id_Keyence DESC)
		UPDATE QAGATE_1_KeyenceData SET Coup_Denture_2 = (SELECT TOP(1) Coup_Denture_2 FROM #tempDATA ORDER BY Id_Keyence DESC) WHERE Id_Keyence = (SELECT TOP(1) Id_Keyence FROM QAGATE_1_KeyenceData ORDER BY Id_Keyence DESC)
		UPDATE QAGATE_1_KeyenceData SET Chanfrein_1 = (SELECT TOP(1) Chanfrein_1 FROM #tempDATA ORDER BY Id_Keyence DESC) WHERE Id_Keyence = (SELECT TOP(1) Id_Keyence FROM QAGATE_1_KeyenceData ORDER BY Id_Keyence DESC)
		UPDATE QAGATE_1_KeyenceData SET Chanfrein_2 = (SELECT TOP(1) Chanfrein_2 FROM #tempDATA ORDER BY Id_Keyence DESC) WHERE Id_Keyence = (SELECT TOP(1) Id_Keyence FROM QAGATE_1_KeyenceData ORDER BY Id_Keyence DESC)
		UPDATE QAGATE_1_KeyenceData SET Chanfrein_3 = (SELECT TOP(1) Chanfrein_3 FROM #tempDATA ORDER BY Id_Keyence DESC) WHERE Id_Keyence = (SELECT TOP(1) Id_Keyence FROM QAGATE_1_KeyenceData ORDER BY Id_Keyence DESC)
		UPDATE QAGATE_1_KeyenceData SET Chanfrein_4 = (SELECT TOP(1) Chanfrein_4 FROM #tempDATA ORDER BY Id_Keyence DESC) WHERE Id_Keyence = (SELECT TOP(1) Id_Keyence FROM QAGATE_1_KeyenceData ORDER BY Id_Keyence DESC)
																									-- Ajout des données de la dernière pièce mesurée dans la table QAGATE_1_KeyenceData
		DROP TABLE #tempDATA																		-- Suppression de la table temporaire #tempDATA
	END