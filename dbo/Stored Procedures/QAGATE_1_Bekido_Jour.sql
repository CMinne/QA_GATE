-- =============================================
-- Author: <Minne Charly>
-- Create date: <29/10/2019>
-- Update: <14/11/2019>
-- Description:	< Ce programme permet de calculer le Bekido d'une journée entre 06:00:00 et 06:00:00 le lendemain. Ne se base pas sur le numéro de l'OF. >
-- =============================================

-- VALIDER --

-- VALEUR DE SORTIE EN SMALLINT --


CREATE PROCEDURE [dbo].[QAGATE_1_Bekido_Jour]

AS

	SET NOCOUNT ON																					-- Obligatoire

	DECLARE 
			@Date_H DATE,																			-- Date avec 6h de moins que la date du jour
			@DateTime_H DATETIME,																	-- Date avec 6h de moins que la date du jour + l'heure 06:00:00
			@Bekido_S INT,																			-- Ex : Temps (secondes) entre 06:00:00 08/10/19 et l'heure actuelle 10:23:15 08/10/19
			@Prevision INT,																			-- Nombre de pieces prévues à un moment précis
			@Bekido SMALLINT,																		-- Bekido du jour en pourcent
			@Piece_Actu INT,																		-- Ex : Pieces analysées entre 06:00:00 08/10/19 et l'heure actuelle 04:23:15 09/10/19
			@Cycle DECIMAL(4,1),																	-- Temps deQAGATE_1_Cyclereference 1
			@Last_Id_Piece INT,																		-- Numéro d'OF de la dernière pièce
			@First_Id_Piece INT,																	-- Numéro du premier OF après 06:00:00
			@OF VARCHAR(10)																			-- Numéro de l'OF

BEGIN

	SELECT @Date_H = CAST(DATEADD(HOUR, -6, GETDATE()) AS DATE)										-- Date actuelle -6h

	SELECT @DateTime_H = CAST(@Date_H AS DATETIME) + CAST('06:00:00' AS DATETIME)					-- Ajout de l'heure 06:00:00 à cette date

	SET @First_Id_Piece = (SELECT TOP(1) Id_Piece FROM QAGATE_1_MainTable WHERE Heure_Reseau >= @DateTime_H ORDER BY Heure_Reseau ASC)
																									-- Récupération de l'id du premier OF après 06:00:00
	SELECT @Last_Id_Piece = MAX(Id_Piece) 
	FROM QAGATE_1_MainTable																			-- Récupération de l'id de la dernière pièce

	SELECT @OF = Current_OF 
	FROM QAGATE_1_MainTable 
	WHERE Id_Piece = @Last_Id_Piece																	-- Numéro d'OF

	IF((SELECT Current_OF FROM QAGATE_1_MainTable WHERE Id_Piece = @First_Id_Piece) != (SELECT Current_OF FROM QAGATE_1_MainTable WHERE Id_Piece = @Last_Id_Piece))
		BEGIN																						-- Vérifie si la référence de la pièce juste après 06:00:00 et la dernière sont identiques


			SELECT @Bekido_S = DATEDIFF(SECOND, (SELECT TOP(1) Heure_Reseau FROM QAGATE_1_MainTable WHERE Current_OF = @OF ORDER BY Heure_Reseau ASC), GETDATE())
																									-- Calcul le temps entre l'heure de la premièrre pièce de la deuxième référence et maintenant
			SELECT @Cycle = Temps_Cycle 
			FROM QAGATE_1_Cycle
			WHERE Id_Client = (SELECT Id_Client FROM QAGATE_1_Reference WHERE Names = (SELECT Reference FROM QAGATE_1_MainTable WHERE Id_Piece = @Last_Id_Piece))							
																									-- Récupération temps de Cycle
			SELECT @Prevision = ROUND((CAST(@Bekido_S AS FLOAT)/CAST(@Cycle AS FLOAT)), 0)
																									-- Calcul prevision pièce (CAST ET ROUND pour permettre d'arrondir de manière scientifique)
		END
	ELSE
		BEGIN
			SELECT @Bekido_S = DATEDIFF(SECOND, @DateTime_H, GETDATE())								-- Récupération des secondes entre maintenant et la date + heure

			SELECT @Cycle = Temps_Cycle 
			FROM QAGATE_1_Cycle
			WHERE Id_Client = (SELECT Id_Client FROM QAGATE_1_Reference WHERE Names = (SELECT Reference FROM QAGATE_1_MainTable WHERE Id_Piece = @Last_Id_Piece))
																									-- Récupération temps de cycle
			SELECT @Prevision = ROUND((CAST(@Bekido_S AS FLOAT)/CAST(@Cycle AS FLOAT)),0)			-- Calcul prevision pièce (CAST ET ROUND pour permettre d'arrondir de manière scientifique)
			
		END
	

	SELECT @Piece_Actu = COUNT(Id_Piece)															-- Récupération du nombres de pièces depuis date + heure (avec sécurité)
	FROM QAGATE_1_MainTable		 
	WHERE (((OK = 0 AND (Keyence_Etat=0 AND Kogame_Etat=0))    OR    (OK = 1 AND (Keyence_Etat = 1 OR Kogame_Etat = 1)))   AND   Heure_Reseau > @DateTime_H  AND Current_OF = @OF)																					

	IF(@Prevision  > 0)																				-- Condition pour éviter de diviser par 0 (Peu de chance mais sécurité). Sinon @Bekido retourne NULL
		SELECT @Bekido = ROUND((CAST(@Piece_Actu AS FLOAT)*100)/CAST(@Prevision AS FLOAT), 0)		-- Calcul Bekido (CAST ET ROUND pour permettre d'arrondir de manière scientifique)
	ELSE
		SELECT @Bekido = 0

	SELECT @Bekido AS 'Bekido'																		-- Affichage de la valeur de sortie procédure
	
END


-- ATTENTION 28 FEVRIER (A TESTER)