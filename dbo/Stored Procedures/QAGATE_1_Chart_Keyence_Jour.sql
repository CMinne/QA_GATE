-- =============================================
-- Author: <Minne Charly>
-- Create date: <29/10/2019>
-- Update: <29/10/2019>
-- Description:	< Sort les valeurs du top 3 des outils problématiques par jour entre 06:00:00 et 06:00:00 le lendemain.  Ne se base pas sur le numéro de l'OF. >
-- =============================================

-- VALIDER --

-- PLUSIEURS SORTIES --

CREATE PROCEDURE [dbo].[QAGATE_1_Chart_Keyence_Jour]
	
AS

	SET NOCOUNT ON

	DECLARE
			@Date_H DATE,																			-- Date avec 6h de moins que la date du jour
			@DateTime_H DATETIME,																	-- Date avec 6h de moins que la date du jour + l'heure 06:00:00
			@First SMALLINT,																		-- Valeur du problème en top 1
			@First_Name VARCHAR(15),																-- Nom du problème en top 1
			@Second SMALLINT,																		-- Valeur du problème en top 2
			@Second_Name VARCHAR(15),																-- Nom du problème en top 2
			@Third SMALLINT,																		-- Valeur du problème en top 3
			@Third_Name VARCHAR(15),																-- Nom du problème en top 3
			@Other SMALLINT,																		-- Valeur des autres problèmes
			@OF VARCHAR(10),																		-- Numero du dernier OF
			@DateOF DATETIME,																		-- Date de début de l'OF
			@Last_Id_Piece INT,																		-- Numéro d'id de la dernière pièce
			@Reference VARCHAR(15)																	-- Reference PG du dernier OF

BEGIN

	SELECT @Date_H = CAST(DATEADD(HOUR, -6, GETDATE()) AS DATE)										-- Date actuelle -6h

	SELECT @DateTime_H = CAST(@Date_H AS DATETIME) + CAST('06:00:00' AS DATETIME)					-- Ajout de l'heure 06:00:00 à cette date

	SELECT @Last_Id_Piece = MAX(idPiece) 
	FROM QAGATE_1_MainTable																			-- Récupération de l'id de la dernière pièce

	SELECT @OF = currentOF 
	FROM QAGATE_1_MainTable 
	WHERE idPiece = @Last_Id_Piece																	-- Numéro d'OF

	CREATE TABLE #temp_table 																		-- Création d'une table temporaire 
	(			
				Id SMALLINT PRIMARY KEY IDENTITY (1, 1),
				Name_NOK VARCHAR(15),																-- Nom de l'outil											
				Nbr_NOK SMALLINT																	-- Nombre de NOK
	)

	INSERT INTO #temp_table (Name_NOK		  , Nbr_NOK																																	  ) 
	VALUES					('Double_Taillage', (SELECT COUNT(doubleTaillage) FROM QAGATE_1_KeyenceData WHERE (doubleTaillage = 1 AND timeStamp >= @DateTime_H AND currentOF = @OF)))
																									-- Insertion dans #temp_table du nombre de NOK pour le double taillage

	INSERT INTO #temp_table (Name_NOK		 , Nbr_NOK																																   ) 
	VALUES					('Coup_Denture_1', (SELECT COUNT(coupDenture1) FROM QAGATE_1_KeyenceData WHERE (coupDenture1 = 1 AND timeStamp >= @DateTime_H AND currentOF = @OF)))
																									-- Insertion dans #temp_table du nombre de NOK pour le coup denture 1

	INSERT INTO #temp_table (Name_NOK		 , Nbr_NOK																																   ) 
	VALUES					('Coup_Denture_2', (SELECT COUNT(coupDenture2) FROM QAGATE_1_KeyenceData WHERE (coupDenture2 = 1 AND timeStamp >= @DateTime_H AND currentOF = @OF)))
																									-- Insertion dans #temp_table du nombre de NOK pour le coup denture 2

	INSERT INTO #temp_table (Name_NOK	  , Nbr_NOK																															  ) 
	VALUES					('Chanfrein_1', (SELECT COUNT(chanfrein1) FROM QAGATE_1_KeyenceData WHERE (chanfrein1 = 1 AND timeStamp >= @DateTime_H AND currentOF = @OF)))
																									-- Insertion dans #temp_table du nombre de NOK pour le chanfrein 1

	INSERT INTO #temp_table (Name_NOK	  , Nbr_NOK																															  ) 
	VALUES					('Chanfrein_2', (SELECT COUNT(chanfrein2) FROM QAGATE_1_KeyenceData WHERE (chanfrein2 = 1 AND timeStamp >= @DateTime_H AND currentOF = @OF)))
																									-- Insertion dans #temp_table du nombre de NOK pour le chanfrein 2

	INSERT INTO #temp_table (Name_NOK	  , Nbr_NOK																															  ) 
	VALUES					('Chanfrein_3', (SELECT COUNT(chanfrein3) FROM QAGATE_1_KeyenceData WHERE (chanfrein3 = 1 AND timeStamp >= @DateTime_H AND currentOF = @OF)))
																									-- Insertion dans #temp_table du nombre de NOK pour le chanfrein 3

	INSERT INTO #temp_table (Name_NOK	  , Nbr_NOK																															  ) 
	VALUES					('Chanfrein_4', (SELECT COUNT(chanfrein4) FROM QAGATE_1_KeyenceData WHERE (chanfrein4 = 1 AND timeStamp >= @DateTime_H AND currentOF = @OF)))
																									-- Insertion dans #temp_table du nombre de NOK pour le chanfrein 4

	SET @First = (SELECT TOP(1) Nbr_NOK FROM #temp_table ORDER BY Nbr_NOK DESC, Name_NOK ASC)		-- Séléction de la valeur du top 1

	SET @First_Name = (SELECT TOP(1) Name_NOK FROM #temp_table ORDER BY Nbr_NOK DESC, Name_NOK ASC)	-- Séléction du nom du top 1

	DELETE FROM #temp_table 
	WHERE Id = (SELECT TOP(1) Id FROM #temp_table ORDER BY Nbr_NOK DESC, Name_NOK ASC)				-- Suppression du top 1


	SET @Second = (SELECT TOP(1) Nbr_NOK FROM #temp_table ORDER BY Nbr_NOK DESC, Name_NOK ASC)		-- Séléction de la valeur du top 2

	SET @Second_Name = (SELECT TOP(1) Name_NOK FROM #temp_table ORDER BY Nbr_NOK DESC, Name_NOK ASC)-- Séléction du nom du top 2

	DELETE FROM #temp_table 
	WHERE Id = (SELECT TOP(1) Id FROM #temp_table ORDER BY Nbr_NOK DESC, Name_NOK ASC)				-- Suppression du top 2

	SET @Third = (SELECT TOP(1) Nbr_NOK FROM #temp_table ORDER BY Nbr_NOK DESC, Name_NOK ASC)		-- Séléction de la valeur du top 3

	SET @Third_Name = (SELECT TOP(1) Name_NOK FROM #temp_table ORDER BY Nbr_NOK DESC, Name_NOK ASC)	-- Séléction du nom du top 3

	DELETE FROM #temp_table 
	WHERE Id = (SELECT TOP(1) Id FROM #temp_table ORDER BY Nbr_NOK DESC, Name_NOK ASC)				-- Suppression du top 3

	SET @Other = (SELECT SUM(Nbr_NOK) FROM #temp_table)												-- Séléction de la valeur des autres

	SELECT @First_Name AS 'First_Name', @First AS 'FirstVal', @Second_Name AS 'Second_Name', @Second AS 'SecondVal', @Third_Name AS 'Third_Name', @Third AS 'ThirdVal', @Other AS 'OtherVal'

	DROP TABLE #temp_table																			-- Suppression de la table temporaire
END