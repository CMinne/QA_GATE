-- =============================================
-- Author: <Minne Charly>
-- Create date: <10/10/2019>
-- Update : <13/11/2019>
-- Description:	< Ce programme permet d'obtenir les prévions, les pièces actuelles, et le delta du jour. Ne se base pas sur le numéro de l'OF. >
-- =============================================

-- VALIDER --

CREATE PROCEDURE [dbo].[QAGATE_1_Prevision_Jour]

AS

	SET NOCOUNT ON

	DECLARE 
			@Date_H DATE,																			-- Date avec 6h de moins que la date du jour
			@DateTime_H DATETIME,																	-- Date avec 6h de moins que la date du jour + 06:00:00
			@Temps_S INT,																			-- Ex : Temps (secondes) entre 06:00:00 08/10/19 et l'heure actuelle 10:23:15 08/10/19
			@Prevision INT,																			-- Ex : Prévision de pièce entre 06:00:00 08/10/19 et l'heure actuelle 04:52:11 09/10/19
			@Actuel INT,																			-- Ex : Actuel de pièce entre 06:00:00 08/10/19 et l'heure actuelle 04:52:11 09/10/19
			@Delta INT,																				-- Ex : Delta de pièce entre 06:00:00 08/10/19 et l'heure actuelle 04:52:11 09/10/19
			@Last_Id_Piece INT,																		-- Numéro d'OF de la dernière pièce
			@First_Id_Piece INT,																	-- Numéro du premier OF après 06:00:00
			@OF VARCHAR(10),																		-- Numéro OF
			@Cycle DECIMAL(4,1)																		-- Temps de cycle


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

	SELECT @Actuel = COUNT(Id_Piece)																-- Récupération du nombres de pièces depuis date + heure (avec sécurité)
	FROM QAGATE_1_MainTable 
	WHERE (((OK = 0 AND (Keyence_Etat=0 AND Kogame_Etat=0))    OR    (OK = 1 AND (Keyence_Etat = 1 OR Kogame_Etat = 1)))   AND   Heure_Reseau > @DateTime_H AND Current_OF = @OF)


	IF((SELECT Reference FROM QAGATE_1_MainTable WHERE Id_Piece = @First_Id_Piece) != (SELECT Reference FROM QAGATE_1_MainTable WHERE Id_Piece = @Last_Id_Piece))
		BEGIN																						-- Vérifie si la référence de la pièce juste après 06:00:00 et la dernière sont identiques
																									-- Si pas, alors faire ceci
			SELECT @OF = Current_OF 
			FROM QAGATE_1_MainTable
			WHERE Id_Piece = @Last_Id_Piece															-- Numéro d'OF de la deuxième référence
			SELECT @Temps_S = DATEDIFF(second, (SELECT TOP(1) Heure_Reseau FROM QAGATE_1_MainTable WHERE Current_OF = @OF ORDER BY Heure_Reseau ASC), GETDATE())
																									-- Calcul le temps entre l'heure de la premièrre pièce de la deuxième référence et maintenant
			SELECT @Cycle = Temps_Cycle 
			FROM QAGATE_1_Cycle 
			WHERE Id_Client = (SELECT Id_Client FROM QAGATE_1_Reference WHERE Names = (SELECT Reference FROM QAGATE_1_MainTable WHERE Id_Piece = @Last_Id_Piece))							
																									-- Récupération temps de cycle reference 2
			SELECT @Prevision = ROUND((CAST(@Temps_S AS FLOAT)/CAST(@Cycle AS FLOAT)), 0)
																									-- Calcul prevision pièce (CAST ET ROUND pour permettre d'arrondir de manière scientifique)
		END
	ELSE
		BEGIN
			SELECT @Temps_S = DATEDIFF(second, @DateTime_H, GETDATE())								-- Récupération des secondes entre maintenant et la date + heure

			SELECT @Cycle = Temps_Cycle 
			FROM QAGATE_1_Cycle 
			WHERE Id_Client = (SELECT Id_Client FROM QAGATE_1_Reference WHERE Names = (SELECT Reference FROM QAGATE_1_MainTable WHERE Id_Piece = @Last_Id_Piece))
																									-- Récupération temps de cycle
			SELECT @Prevision = ROUND((CAST(@Temps_S AS FLOAT)/CAST(@Cycle AS FLOAT)),0)			-- Calcul prevision pièce (CAST ET ROUND pour permettre d'arrondir de manière scientifique)

		END


	SELECT @Delta = @Actuel - @Prevision															-- Calcul Delta

	SELECT @Prevision AS 'Prevision', @Actuel AS 'Actuel', @Delta AS 'Delta'								
																									-- Affichage des valeurs de sortie procédure
END