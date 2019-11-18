-- =============================================
-- Author: <Minne Charly>
-- Create date: <29/10/2019>
-- Update: <12/11/2019>
-- Description:	< Ce programme permet de calculer le Bekido d'un OF.>
-- =============================================

-- VALIDER --

-- VALEUR DE SORTIE EN SMALLINT --

CREATE PROCEDURE [dbo].[QAGATE_1_Bekido_OF]

AS

	SET NOCOUNT ON

	DECLARE 
			@DateTime_OF_Last DATETIME,																-- Date de la dernière pièce de l'OF
			@DateTime_OF_First DATETIME,															-- Date de la premiere pièce de l'OF
			@Bekido_S INT,																			-- Ex : Temps (secondes) entre 06:00:00 08/10/19 et l'heure actuelle  04:23:15 09/10/19
			@Prevision INT,																			-- Nombre de pieces prévues à un moment précis
			@Bekido SMALLINT,																		-- Bekido du jour en pourcent
			@Last_Id_Piece INT,																		-- Numéro d'OF de la dernière pièce
			@OF VARCHAR(10),																		-- OF Actuel
			@Piece_Actu INT,																		-- Ex : Pieces analysées entre 06:00:00 08/10/19 et l'heure actuelle  04:23:15 09/10/19
			@Cycle DECIMAL(4,1),																	-- Temps de cycle
			@Count_Piece INT,
			@Temp_Count_Piece INT,
			@Heure TIME(0),
			@Date DATE

BEGIN

	SELECT @Last_Id_Piece = MAX(idPiece) 
	FROM QAGATE_1_MainTable																			-- Récupération de l'id de la dernière pièce

	SELECT @OF = currentOF 
	FROM QAGATE_1_MainTable 
	WHERE idPiece = @Last_Id_Piece																	-- Récupération du code du dernier OF

	SET @DateTime_OF_First = (SELECT TOP(1) timeStamp FROM QAGATE_1_MainTable WHERE currentOF = @OF ORDER BY timeStamp ASC)
																									-- Récupération de la date de la première pièce de l'OF

	IF(CAST(@DateTime_OF_First AS TIME(0)) >= '06:00:00' AND CAST(@DateTime_OF_First AS TIME(0)) < '14:00:00')
		BEGIN

			SET @Bekido_S = DATEDIFF(SECOND, @DateTime_OF_First, CONCAT(CAST(@DateTime_OF_First AS DATE), ' ', '14:00:00'))
			
																										-- Calcul du temps en seconde entre la première pièce et la dernière pièce de l'OF

			SET @Heure = CAST('14:00:00' AS TIME(0))
			SET @Date = CAST(@DateTime_OF_First AS DATE)

		END

	ELSE IF(CAST(@DateTime_OF_First AS TIME(0)) >= '14:00:00' AND CAST(@DateTime_OF_First AS TIME(0)) < '22:00:00')
		BEGIN

			SET @Bekido_S = DATEDIFF(SECOND, @DateTime_OF_First, CONCAT(CAST(@DateTime_OF_First AS DATE), ' ', '22:00:00'))						
																										-- Calcul du temps en seconde entre la première pièce et la dernière pièce de l'OF
			
			SET @Heure = CAST('22:00:00' AS TIME(0))
			SET @Date = CAST(@DateTime_OF_First AS DATE)

		END

	ELSE
		BEGIN

			SET @Bekido_S = DATEDIFF(SECOND, @DateTime_OF_First, CONCAT(DATEADD(DAY, 1, CAST(@DateTime_OF_First AS DATE)), ' ', '06:00:00'))						
																										-- Calcul du temps en seconde entre la première pièce et la dernière pièce de l'OF.

			SET @Heure = CAST('06:00:00' AS TIME(0))
			SET @Date = DATEADD(DAY, 1, CAST(@DateTime_OF_First AS DATE))
		
		END
	
	WHILE(1=1)
		BEGIN
			SELECT @Temp_Count_Piece = COUNT(idPiece) 
			FROM QAGATE_1_MainTable 
			WHERE currentOF = @OF AND timeStamp >= CONCAT(@Date, ' ', DATEADD(HOUR, 8, @Heure))


			IF(NOT(@Temp_Count_Piece = 0))
				BEGIN
					IF(@Heure = '06:00:00' OR @Heure = '14:00:00')
						BEGIN

							SELECT @Temp_Count_Piece = COUNT(idPiece) 
							FROM QAGATE_1_MainTable 
							WHERE currentOF = @OF AND (timeStamp >= CONCAT(CAST(@Date AS DATE), ' ', @Heure) AND timeStamp < CONCAT(CAST(@Date AS DATE), ' ', DATEADD(HOUR, 8, @Heure)))

							IF(NOT(@Temp_Count_Piece = 0))
								BEGIN

									SET @Bekido_S += DATEDIFF(SECOND, '00:00:00', '08:00:00' )

								END
							SET @Heure = CAST(DATEADD(HOUR, 8, @Heure) AS TIME(0))

						END

					ELSE
						BEGIN

							SELECT @Temp_Count_Piece = COUNT(idPiece) 
							FROM QAGATE_1_MainTable 
							WHERE currentOF = @OF AND (timeStamp >= CONCAT(CAST(@Date AS DATE), ' ', @Heure) AND timeStamp < CONCAT(DATEADD(DAY, 1, CAST(@Date AS DATE)), ' ', DATEADD(HOUR, 8, @Heure)))

							IF(NOT(@Temp_Count_Piece = 0))
								BEGIN

									SET @Bekido_S += DATEDIFF(SECOND, '00:00:00', '08:00:00' )

								END
							SET @Heure = CAST(DATEADD(HOUR, 8, @Heure) AS TIME(0))
							SET @Date = DATEADD(DAY, 1, @Date)
						END

					CONTINUE
				END

			ELSE
				BREAK
			
		END
	SET @DateTime_OF_Last = (SELECT TOP(1) timeStamp FROM QAGATE_1_MainTable WHERE currentOF = @OF ORDER BY timeStamp DESC)
																									-- Récupération de la date de la dernière pièce de l'OF

	SELECT @Piece_Actu = COUNT(idPiece)																-- Récupération du nombres de pièces contrôlées de l'OF
	FROM QAGATE_1_MainTable 
	WHERE (((OK = 0 AND (keyenceEtat=0 AND kogameEtat=0))    OR    (OK = 1 AND (keyenceEtat = 1 OR kogameEtat = 1)))   AND   currentOF = @OF)
	

	SET @Bekido_S += DATEDIFF(SECOND, CONCAT(@Date, ' ', @Heure), @DateTime_OF_Last)				-- Calcul du temps en seconde entre la première pièce et la dernière pièce de l'OF

																									
	SELECT @Cycle = tempsCycle 
	FROM QAGATE_1_Cycle 
	WHERE idClient = (SELECT idClient FROM QAGATE_1_Reference WHERE nameReference = (SELECT reference FROM QAGATE_1_MainTable WHERE idPiece = @Last_Id_Piece))
																									-- Récupération temps de cycle

	SELECT @Prevision = ROUND(CAST(@Bekido_S AS FLOAT)/CAST(@Cycle AS FLOAT), 0)					-- Calcul prevision pièce

	IF(@Prevision  > 0)																				-- Condition pour éviter de diviser par 0 (Peu de chance mais sécurité)
		SELECT @Bekido = ROUND((CAST(@Piece_Actu AS FLOAT)*100)/CAST(@Prevision AS FLOAT), 0)		-- Calcul Bekido
	ELSE
		SELECT @Bekido = 0

	SELECT @Bekido AS 'Bekido'																		-- Affichage de la valeur de sortie procédure

END