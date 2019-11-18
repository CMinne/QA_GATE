-- =============================================
-- Author: <Minne Charly>
-- Create date: <29/10/2019>
-- Update: <12/11/2019>
-- Description:	< Sort les valeurs du top 3 des outils problématiques par OF. >
-- =============================================

-- VALIDER --

-- PLUSIEURS SORTIES --

CREATE PROCEDURE [dbo].[QAGATE_1_Chart_Keyence_OF]
	
AS

	SET NOCOUNT ON

	DECLARE
			@First SMALLINT,																		-- Valeur du problème en top 1
			@First_Name VARCHAR(15),																-- Nom du problème en top 1
			@Last_Id_Piece INT,																		-- Numéro d'id de la dernière pièce
			@OF VARCHAR(10),																		-- Numero du dernier OF
			@Other SMALLINT,																		-- Valeur des autres problèmes
			@Reference VARCHAR(15),																	-- Reference PG du dernier OF
			@Second SMALLINT,																		-- Valeur du problème en top 2
			@Second_Name VARCHAR(15),																-- Nom du problème en top 2
			@Third SMALLINT,																		-- Valeur du problème en top 3
			@Third_Name VARCHAR(15)																	-- Nom du problème en top 3
			
BEGIN

	SELECT @Last_Id_Piece = MAX(idPiece) 
	FROM QAGATE_1_MainTable																			-- Récupération de l'id e la dernière pièce

	SELECT @OF = currentOF 
	FROM QAGATE_1_MainTable 
	WHERE idPiece = @Last_Id_Piece																	-- Récupération du code du dernier OF


	CREATE TABLE #temp_table 																		-- Création d'une table temporaire 
	(			
				Id SMALLINT PRIMARY KEY IDENTITY (1, 1),
				Name_NOK VARCHAR(15),																-- Nom de l'outil											
				Nbr_NOK SMALLINT																	-- Nombre de NOK
	)

	INSERT INTO #temp_table (Name_NOK		  , Nbr_NOK																										   ) 
	VALUES					('Double_Taillage', (SELECT COUNT(doubleTaillage) FROM QAGATE_1_KeyenceData WHERE (doubleTaillage = 1 AND currentOF = @OF)))
																									-- Insertion dans #temp_table du nombre de NOK pour le double taillage																							-- Insertion dans #temp_table du nombre de NOK pour le double taillage

	INSERT INTO #temp_table (Name_NOK		 , Nbr_NOK																										) 
	VALUES					('Coup_Denture_1', (SELECT COUNT(coupDenture1) FROM QAGATE_1_KeyenceData WHERE (coupDenture1 = 1 AND currentOF = @OF)))
																									-- Insertion dans #temp_table du nombre de NOK pour le coup denture 1

	INSERT INTO #temp_table (Name_NOK		 , Nbr_NOK																										) 
	VALUES					('Coup_Denture_2', (SELECT COUNT(coupDenture2) FROM QAGATE_1_KeyenceData WHERE (coupDenture2 = 1 AND currentOF = @OF)))
																									-- Insertion dans #temp_table du nombre de NOK pour le coup denture 2

	INSERT INTO #temp_table (Name_NOK	  , Nbr_NOK																								   ) 
	VALUES					('Chanfrein_1', (SELECT COUNT(chanfrein1) FROM QAGATE_1_KeyenceData WHERE (chanfrein1 = 1 AND currentOF = @OF)))
																									-- Insertion dans #temp_table du nombre de NOK pour le chanfrein 1

	INSERT INTO #temp_table (Name_NOK	  , Nbr_NOK																								   ) 
	VALUES					('Chanfrein_2', (SELECT COUNT(chanfrein2) FROM QAGATE_1_KeyenceData WHERE (chanfrein2 = 1 AND currentOF = @OF)))
																									-- Insertion dans #temp_table du nombre de NOK pour le chanfrein 2

	INSERT INTO #temp_table (Name_NOK	  , Nbr_NOK																								   ) 
	VALUES					('Chanfrein_3', (SELECT COUNT(chanfrein3) FROM QAGATE_1_KeyenceData WHERE (chanfrein3 = 1 AND currentOF = @OF)))
																									-- Insertion dans #temp_table du nombre de NOK pour le chanfrein 3

	INSERT INTO #temp_table (Name_NOK	  , Nbr_NOK																								   ) 
	VALUES					('Chanfrein_4', (SELECT COUNT(chanfrein4) FROM QAGATE_1_KeyenceData WHERE (chanfrein4 = 1 AND currentOF = @OF)))
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