-- =============================================
-- Author: <Minne Charly>
-- Create date: <15/11/2019>
-- Update : <15/11/2019>
-- Description:	< Ce programme permet le pourcentage de rebuts Keyence et Kogame par équipe.>
-- =============================================

-- VALIDER --

-- VALEUR DE SORTIE EN SMALLINT --

-- /!\ ATTENTION ALGORITHM WEEK-END PAS ENCORE CODE --

CREATE PROCEDURE [dbo].[QAGATE_1_Rebut_Team]
AS

	SET NOCOUNT ON

	DECLARE 
			@Date_H DATE,																			-- Date avec 6h de moins que la date du jour
			@DateTime_H DATETIME,																	-- Date avec 6h de moins que la date du jour + heure fixe
			@DateTime_H2 DATETIME,																	-- Date avec 6h de moins que la date du jour + autre heure fixe
			@Last_Id_Piece INT,																		-- Numéro d'OF de la dernière pièce
			@OF VARCHAR(10),																		-- Numéro de l'OF
			@Numero_Jour TINYINT,																	-- Numéro du jour, permet de différencier week-end et semaine
			@Rebut_Tot INT,																			-- Ex : Nbr de rebut entre 06:00:00 08/10/19 et 04:42:16 09/10/19
			@Rebut_Key INT,																			-- Ex : Nbr de rebut keyence entre 06:00:00 08/10/19 et 04:42:16 09/10/19
			@Rebut_Kog INT,																			-- Ex : Nbr de rebut kogame entre 06:00:00 08/10/19 et 04:42:16 09/10/19
			@Pourcent_Key SMALLINT,																	-- Pourcentage de pièce mauvaise Keyence 
			@Pourcent_Kog SMALLINT																	-- Pourcentage de pièce mauvaise Kogame

BEGIN

	SELECT @Date_H = CAST(DATEADD(HOUR,-6,GETDATE()) AS DATE)										-- Date actuelle -6h

	SELECT @DateTime_H = CAST(@Date_H AS DATETIME) + CAST('06:00:00' AS DATETIME)					-- Ajout de l'heure 06:00:00 à cette date

	SELECT @Last_Id_Piece = MAX(Id_Piece) 
	FROM QAGATE_1_MainTable																			-- Récupération de l'id de la dernière pièce

	SELECT @OF = Current_OF 
	FROM QAGATE_1_MainTable 
	WHERE Id_Piece = @Last_Id_Piece																	-- Numéro d'OF

-- Pour chaque équipe
	SET @Numero_Jour = DATEPART(DW, GETDATE());														-- Détermine le numéro du jour actuel
	-- Semaine 
	IF(@Numero_Jour != 1 OR @Numero_Jour != 7)														-- Détermine si on est le week-end
		BEGIN
			IF(('06:00:00' <= CAST(GETDATE() AS TIME)) AND (CAST(GETDATE() AS TIME) < '14:00:00'))	-- Détermine si on est entre 06:00:00 et 14:00:00

				BEGIN
					SELECT @DateTime_H = CAST(@Date_H AS DATETIME) + CAST('06:00:00' AS DATETIME)	-- Ajout de l'heure 06:00:00 à cette date
					SELECT @DateTime_H2 = CAST(@Date_H AS DATETIME) + CAST('14:00:00' AS DATETIME)	-- Ajout de l'heure 14:00:00 à cette date

					SELECT @Rebut_Tot = COUNT(Id_Piece)																-- Récupération du nombres de rebut depuis date + heure (avec sécurité)  
					FROM QAGATE_1_MainTable
					WHERE (OK = 1 AND (Keyence_Etat = 1 OR Kogame_Etat = 1) AND (@DateTime_H < Heure_Reseau AND Heure_Reseau < @DateTime_H2) AND Current_OF = @OF)

					SELECT @Rebut_Key = COUNT(Id_Piece)																-- Récupération du nombres de rebut keyence depuis date + heure (avec sécurité)  
					FROM QAGATE_1_MainTable 
					WHERE (OK = 1 AND (Keyence_Etat = 1 AND Kogame_Etat = 0)  AND (@DateTime_H < Heure_Reseau AND Heure_Reseau < @DateTime_H2) AND Current_OF = @OF)

					SELECT @Rebut_Kog = COUNT(Id_Piece)																-- Récupération du nombres de rebut kogame depuis date + heure (avec sécurité)  
					FROM QAGATE_1_MainTable 
					WHERE (OK = 1 AND (Keyence_Etat = 0 AND Kogame_Etat = 1) AND (@DateTime_H < Heure_Reseau AND Heure_Reseau < @DateTime_H2) AND Current_OF = @OF)

				END

			ELSE IF(('14:00:00' <= CAST(GETDATE() AS TIME)) AND (CAST(GETDATE() AS TIME) < '22:00:00'))	
																									-- Détermine si on est entre 14:00:00 et 22:00:00
				BEGIN

					SELECT @DateTime_H = CAST(@Date_H AS DATETIME) + CAST('14:00:00' AS DATETIME)	-- Ajout de l'heure 14:00:00 à cette date
					SELECT @DateTime_H2 = CAST(@Date_H AS DATETIME) + CAST('22:00:00' AS DATETIME)	-- Ajout de l'heure 22:00:00 à cette date

					SELECT @Rebut_Tot = COUNT(Id_Piece)																-- Récupération du nombres de rebut depuis date + heure (avec sécurité)  
					FROM QAGATE_1_MainTable
					WHERE (OK = 1 AND (Keyence_Etat = 1 OR Kogame_Etat = 1) AND (@DateTime_H < Heure_Reseau AND Heure_Reseau < @DateTime_H2) AND Current_OF = @OF)

					SELECT @Rebut_Key = COUNT(Id_Piece)																-- Récupération du nombres de rebut keyence depuis date + heure (avec sécurité)  
					FROM QAGATE_1_MainTable 
					WHERE (OK = 1 AND (Keyence_Etat = 1 AND Kogame_Etat = 0)  AND (@DateTime_H < Heure_Reseau AND Heure_Reseau < @DateTime_H2) AND Current_OF = @OF)

					SELECT @Rebut_Kog = COUNT(Id_Piece)																-- Récupération du nombres de rebut kogame depuis date + heure (avec sécurité)  
					FROM QAGATE_1_MainTable 
					WHERE (OK = 1 AND (Keyence_Etat = 0 AND Kogame_Etat = 1) AND (@DateTime_H < Heure_Reseau AND Heure_Reseau < @DateTime_H2) AND Current_OF = @OF)

				END

			ELSE	-- Entre 22:00:00 et 06:00:00

				BEGIN

					SELECT @DateTime_H = CAST(@Date_H AS DATETIME) + CAST('22:00:00' AS DATETIME)	-- Ajout de l'heure 22:00:00 à cette date
					SELECT @DateTime_H2 = CAST(CAST(DATEADD(HOUR,+2,GETDATE()) AS DATE) AS DATETIME) + CAST('06:00:00' AS DATETIME) -- Ajout de l'heure 06:00:00 à cette date + 1 jour

					SELECT @Rebut_Tot = COUNT(Id_Piece)																-- Récupération du nombres de rebut depuis date + heure (avec sécurité)  
					FROM QAGATE_1_MainTable
					WHERE (OK = 1 AND (Keyence_Etat = 1 OR Kogame_Etat = 1) AND (@DateTime_H < Heure_Reseau AND Heure_Reseau < @DateTime_H2) AND Current_OF = @OF)

					SELECT @Rebut_Key = COUNT(Id_Piece)																-- Récupération du nombres de rebut keyence depuis date + heure (avec sécurité)  
					FROM QAGATE_1_MainTable 
					WHERE (OK = 1 AND (Keyence_Etat = 1 AND Kogame_Etat = 0)  AND (@DateTime_H < Heure_Reseau AND Heure_Reseau < @DateTime_H2) AND Current_OF = @OF)

					SELECT @Rebut_Kog = COUNT(Id_Piece)																-- Récupération du nombres de rebut kogame depuis date + heure (avec sécurité)  
					FROM QAGATE_1_MainTable 
					WHERE (OK = 1 AND (Keyence_Etat = 0 AND Kogame_Etat = 1) AND (@DateTime_H < Heure_Reseau AND Heure_Reseau < @DateTime_H2) AND Current_OF = @OF)

				END

			IF(@Rebut_Key = 0 AND @Rebut_Kog = 0)															-- Condition pour éviter une division par 0
				BEGIN
					SET @Pourcent_Key = 0
					SET @Pourcent_Kog = 0
				END
			ELSE
				BEGIN
					SET @Pourcent_Key = (@Rebut_Key*100)/(@Rebut_Key + @Rebut_Kog)							-- Calcul du pourcentage de rebut Keyence
					SET @Pourcent_Kog = (@Rebut_Kog*100)/(@Rebut_Key + @Rebut_Kog)							-- Calcul du pourcentage de rebut Kogame
				END

			SELECT @Rebut_Tot AS 'Total', @Pourcent_Key AS 'PKeyence', @Pourcent_Kog AS 'PKogame'			-- Affichage des valeurs de sortie procédure								

		END
END