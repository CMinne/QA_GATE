-- =============================================
-- Author: <Minne Charly>
-- Create date: <10/10/2019>
-- Update : <14/11/2019>
-- Description:	< Ce programme permet d'obtenir les prévions, les pièces actuelles, et le delta d'un l'OF. >
-- =============================================

-- VALIDER --

CREATE PROCEDURE [dbo].[QAGATE_1_Prevision_OF]

AS

	SET NOCOUNT ON

	DECLARE 
			@DateTime_OF_Last DATETIME,																-- Date avec 6h de moins que la date du jour
			@DateTime_OF_First DATETIME,															-- Date avec 6h de moins que la date du jour + l'heure 06:00:00
			@Temps_S INT,																			-- Ex : Temps (secondes) entre 06:00:00 08/10/19 et l'heure actuelle  04:23:15 09/10/19
			@Prevision INT,																			-- Ex : Prévision de pièce entre 06:00:00 08/10/19 et l'heure actuelle  04:23:15 09/10/19
			@Actuel INT,																			-- Ex : Actuel de pièce entre 06:00:00 08/10/19 et l'heure actuelle  04:23:15 09/10/19
			@Delta INT,																				-- Ex : Delta de pièce entre 06:00:00 08/10/19 et l'heure actuelle  04:23:15 09/10/19
			@Last_Id_Piece INT,																		-- Numéro d'OF de la dernière pièce
			@OF VARCHAR(10),																		-- Numéro OF
			@Cycle DECIMAL(4,1),																	-- Temps de cycle reference 1
			@Count_Piece INT,
			@Temp_Count_Piece INT,
			@Heure TIME(0),
			@Date DATE

BEGIN

	SELECT @Last_Id_Piece = MAX(Id_Piece) 
	FROM QAGATE_1_MainTable																			-- Récupération de l'id de la dernière pièce

	SELECT @OF = Current_OF 
	FROM QAGATE_1_MainTable 
	WHERE Id_Piece = @Last_Id_Piece																	-- Récupération du code du dernier OF

	SET @DateTime_OF_First = (SELECT TOP(1) Heure_Reseau FROM QAGATE_1_MainTable WHERE Current_OF = @OF ORDER BY Heure_Reseau ASC)
																									-- Récupération de la date de la première pièce de l'OF

	IF(CAST(@DateTime_OF_First AS TIME(0)) >= '06:00:00' AND CAST(@DateTime_OF_First AS TIME(0)) < '14:00:00')
		BEGIN

			SET @Temps_S = DATEDIFF(SECOND, @DateTime_OF_First, CONCAT(CAST(@DateTime_OF_First AS DATE), ' ', '14:00:00'))
			
																										-- Calcul du temps en seconde entre la première pièce et la dernière pièce de l'OF

			SET @Heure = CAST('14:00:00' AS TIME(0))
			SET @Date = CAST(@DateTime_OF_First AS DATE)

		END

	ELSE IF(CAST(@DateTime_OF_First AS TIME(0)) >= '14:00:00' AND CAST(@DateTime_OF_First AS TIME(0)) < '22:00:00')
		BEGIN

			SET @Temps_S = DATEDIFF(SECOND, @DateTime_OF_First, CONCAT(CAST(@DateTime_OF_First AS DATE), ' ', '22:00:00'))						
																										-- Calcul du temps en seconde entre la première pièce et la dernière pièce de l'OF
			
			SET @Heure = CAST('22:00:00' AS TIME(0))
			SET @Date = CAST(@DateTime_OF_First AS DATE)

		END

	ELSE
		BEGIN

			SET @Temps_S = DATEDIFF(SECOND, @DateTime_OF_First, CONCAT(DATEADD(DAY, 1, CAST(@DateTime_OF_First AS DATE)), ' ', '06:00:00'))						
																										-- Calcul du temps en seconde entre la première pièce et la dernière pièce de l'OF.

			SET @Heure = CAST('06:00:00' AS TIME(0))
			SET @Date = DATEADD(DAY, 1, CAST(@DateTime_OF_First AS DATE))
		
		END
	
	WHILE(1=1)
		BEGIN
			SELECT @Temp_Count_Piece = COUNT(Id_Piece) 
			FROM QAGATE_1_MainTable 
			WHERE Current_OF = @OF AND Heure_Reseau >= CONCAT(@Date, ' ', DATEADD(HOUR, 8, @Heure))


			IF(NOT(@Temp_Count_Piece = 0))
				BEGIN
					IF(@Heure = '06:00:00' OR @Heure = '14:00:00')
						BEGIN

							SELECT @Temp_Count_Piece = COUNT(Id_Piece) 
							FROM QAGATE_1_MainTable 
							WHERE Current_OF = @OF AND (Heure_Reseau >= CONCAT(CAST(@Date AS DATE), ' ', @Heure) AND Heure_Reseau < CONCAT(CAST(@Date AS DATE), ' ', DATEADD(HOUR, 8, @Heure)))

							IF(NOT(@Temp_Count_Piece = 0))
								BEGIN

									SET @Temps_S += DATEDIFF(SECOND, '00:00:00', '08:00:00' )

								END
							SET @Heure = CAST(DATEADD(HOUR, 8, @Heure) AS TIME(0))

						END

					ELSE
						BEGIN

							SELECT @Temp_Count_Piece = COUNT(Id_Piece) 
							FROM QAGATE_1_MainTable 
							WHERE Current_OF = @OF AND (Heure_Reseau >= CONCAT(CAST(@Date AS DATE), ' ', @Heure) AND Heure_Reseau < CONCAT(DATEADD(DAY, 1, CAST(@Date AS DATE)), ' ', DATEADD(HOUR, 8, @Heure)))

							IF(NOT(@Temp_Count_Piece = 0))
								BEGIN

									SET @Temps_S += DATEDIFF(SECOND, '00:00:00', '08:00:00' )

								END
							SET @Heure = CAST(DATEADD(HOUR, 8, @Heure) AS TIME(0))
							SET @Date = DATEADD(DAY, 1, @Date)
						END

					CONTINUE
				END

			ELSE
				BREAK
			
		END
	SET @DateTime_OF_Last = (SELECT TOP(1) Heure_Reseau FROM QAGATE_1_MainTable WHERE Current_OF = @OF ORDER BY Heure_Reseau DESC)
																									-- Récupération de la date de la dernière pièce de l'OF

	SELECT @Actuel = COUNT(Id_Piece)															-- Récupération du nombres de pièces contrôlées de l'OF
	FROM QAGATE_1_MainTable 
	WHERE (((OK = 0 AND (Keyence_Etat=0 AND Kogame_Etat=0))    OR    (OK = 1 AND (Keyence_Etat = 1 OR Kogame_Etat = 1)))   AND   Current_OF = @OF)
	

	SET @Temps_S += DATEDIFF(SECOND, CONCAT(@Date, ' ', @Heure), @DateTime_OF_Last)				-- Calcul du temps en seconde entre la première pièce et la dernière pièce de l'OF

																									
	SELECT @Cycle = Temps_Cycle 
	FROM QAGATE_1_Cycle 
	WHERE Id_Client = (SELECT Id_Client FROM QAGATE_1_Reference WHERE Names = (SELECT Reference FROM QAGATE_1_MainTable WHERE Id_Piece = @Last_Id_Piece))
																									-- Récupération temps de cycle

	SELECT @Prevision = ROUND(CAST(@Temps_S AS FLOAT)/CAST(@Cycle AS FLOAT), 0)					-- Calcul prevision pièce


	SELECT @Delta = @Actuel - @Prevision															-- Calcul Delta

	SELECT @Prevision AS 'Prevision', @Actuel AS 'Actuel', @Delta AS 'Delta'								
																									-- Affichage des valeurs de sortie procédure
END