-- =============================================
-- Author: <Minne Charly>
-- Create date: <29/10/2019>
-- Update : <12/11/2019>
-- Description:	< Ce programme permet de calculer le Bekido d'une équipe. Ne se base pas sur le numéro de l'OF. >
-- =============================================

-- VALIDER --

-- VALEUR DE SORTIE EN SMALLINT --

-- /!\ ATTENTION ALGORITHM WEEK-END PAS ENCORE CODE --

CREATE PROCEDURE [dbo].[QAGATE_1_Bekido_Team]
AS

	SET NOCOUNT ON

	DECLARE 
			@Bekido SMALLINT,																		-- Bekido equipe en pourcent
			@Bekido_S INT,																			-- Ex : Temps (secondes) entre 06:00:00 08/10/19 et l'heure actuelle 10:23:15 08/10/19
			@Cycle DECIMAL(4,1),																	-- Temps de cycle nameReference 1
			@Date_H DATE,																			-- Date avec 6h de moins que la date du jour
			@DateTime_H DATETIME,																	-- Date avec 6h de moins que la date du jour + heure fixe
			@DateTime_H2 DATETIME,																	-- Date avec 6h de moins que la date du jour + autre heure fixe
			@First_Id_Piece INT,																	-- Numéro du premier OF après 06:00:00
			@Last_Id_Piece INT,																		-- Numéro d'OF de la dernière pièce
			@Numero_Jour TINYINT,																	-- Numéro du jour, permet de différencier week-end et semaine
			@OF VARCHAR(10),																		-- Numéro de l'OF
			@Piece_Actu INT,																		-- Ex : Pieces analysées entre 06:00:00 08/10/19 et 13:52:11 08/10/19
			@Prevision INT																			-- Piece prévues à un moment précis

BEGIN

	SELECT @Date_H = CAST(DATEADD(HOUR,-6,GETDATE()) AS DATE)										-- Date actuelle -6h

	SELECT @Last_Id_Piece = MAX(idPiece) 
	FROM QAGATE_1_MainTable																			-- Récupération de l'id de la dernière pièce
	
	SET @First_Id_Piece = (SELECT TOP(1) idPiece FROM QAGATE_1_MainTable WHERE timeStamp >= @DateTime_H ORDER BY timeStamp ASC)
																									-- Récupération de l'id du premier OF après 06:00:00
-- Pour chaque équipe
	-- SET @Numero_Jour = DATEPART(DW, GETDATE());													-- Détermine le numéro du jour actuel
	SET @Numero_Jour = 0
	-- Semaine 
	IF(@Numero_Jour != 1 OR @Numero_Jour != 7)														-- Détermine si on est le week-end
		BEGIN
			IF(('06:00:00' <= CAST(GETDATE() AS TIME)) AND (CAST(GETDATE() AS TIME) < '14:00:00'))	-- Détermine si on est entre 06:00:00 et 14:00:00

				BEGIN
					SELECT @DateTime_H = CAST(@Date_H AS DATETIME) + CAST('06:00:00' AS DATETIME)	-- Ajout de l'heure 06:00:00 à cette date
					SELECT @DateTime_H2 = CAST(@Date_H AS DATETIME) + CAST('14:00:00' AS DATETIME)	-- Ajout de l'heure 14:00:00 à cette date

					SELECT @OF = currentOF 
					FROM QAGATE_1_MainTable 
					WHERE idPiece = @Last_Id_Piece													-- Numéro d'OF

					IF((SELECT idClient FROM QAGATE_1_Reference INNER JOIN QAGATE_1_MainTable ON nameReference = reference WHERE idPiece = @First_Id_Piece) != (SELECT idClient FROM QAGATE_1_Reference INNER JOIN QAGATE_1_MainTable ON nameReference = reference WHERE idPiece = @Last_Id_Piece))
						BEGIN																		-- Vérifie si la référence de la pièce juste après 06:00:00 et la dernière sont identiques
																									-- Si pas, alors faire ceci

							SELECT @Bekido_S = DATEDIFF(SECOND, (SELECT TOP(1) timeStamp FROM QAGATE_1_MainTable WHERE currentOF = @OF ORDER BY timeStamp ASC), GETDATE())
																									-- Calcul le temps entre l'heure de la premièrre pièce de la deuxième référence et maintenant

							SELECT @Cycle = tempsCycle 
							FROM QAGATE_1_Cycle 
							WHERE idClient = (SELECT idClient FROM QAGATE_1_Reference WHERE nameReference = (SELECT reference FROM QAGATE_1_MainTable WHERE idPiece = @Last_Id_Piece))							
																									-- Récupération temps de cycle

							SELECT @Prevision = ROUND((CAST(@Bekido_S AS FLOAT)/CAST(@Cycle AS FLOAT)), 0)
																									-- Calcul prevision pièce (CAST ET ROUND pour permettre d'arrondir de manière scientifique)
						END
					ELSE
						BEGIN
							SELECT @Bekido_S = DATEDIFF(second, @DateTime_H, GETDATE())				-- Récupération des secondes entre maintenant et la date + heure

							SELECT @Cycle = tempsCycle 
							FROM QAGATE_1_Cycle 
							WHERE idClient = (SELECT idClient FROM QAGATE_1_Reference WHERE nameReference = (SELECT reference FROM QAGATE_1_MainTable WHERE idPiece = @Last_Id_Piece))
																									-- Récupération temps de cycle

							SELECT @Prevision = ROUND((CAST(@Bekido_S AS FLOAT)/CAST(@Cycle AS FLOAT)),0)
																									-- Calcul prevision pièce (CAST ET ROUND pour permettre d'arrondir de manière scientifique)
						END

					SELECT @Piece_Actu = COUNT(idPiece)												-- Récupération du nombres de pièces depuis date + heure (avec sécurité)
					FROM QAGATE_1_MainTable
					WHERE (((OK = 0 AND (keyenceEtat = 0 AND kogameEtat = 0)) OR (OK = 1 AND (keyenceEtat = 1 OR kogameEtat = 1))) AND (@DateTime_H < timeStamp AND timeStamp < @DateTime_H2) AND currentOF = @OF)

				END

			ELSE IF(('14:00:00' <= CAST(GETDATE() AS TIME)) AND (CAST(GETDATE() AS TIME) < '22:00:00'))	
																									-- Détermine si on est entre 14:00:00 et 22:00:00
				BEGIN

					SELECT @DateTime_H = CAST(@Date_H AS DATETIME) + CAST('14:00:00' AS DATETIME)	-- Ajout de l'heure 14:00:00 à cette date
					SELECT @DateTime_H2 = CAST(@Date_H AS DATETIME) + CAST('22:00:00' AS DATETIME)	-- Ajout de l'heure 22:00:00 à cette date

					SELECT @OF = currentOF 
					FROM QAGATE_1_MainTable 
					WHERE idPiece = @Last_Id_Piece													-- Numéro d'OF

					IF((SELECT idClient FROM QAGATE_1_Reference INNER JOIN QAGATE_1_MainTable ON nameReference = reference WHERE idPiece = @First_Id_Piece) != (SELECT idClient FROM QAGATE_1_Reference INNER JOIN QAGATE_1_MainTable ON nameReference = reference WHERE idPiece = @Last_Id_Piece))
						BEGIN																		-- Vérifie si la référence de la pièce juste après 06:00:00 et la dernière sont identiques
																									-- Si pas, alors faire ceci
							
							SELECT @Bekido_S = DATEDIFF(second, (SELECT TOP(1) timeStamp FROM QAGATE_1_MainTable WHERE currentOF = @OF ORDER BY timeStamp ASC), GETDATE())
																									-- Calcul le temps entre l'heure de la premièrre pièce de la deuxième référence et maintenant

							SELECT @Cycle = tempsCycle 
							FROM QAGATE_1_Cycle 
							WHERE idClient = (SELECT idClient FROM QAGATE_1_Reference WHERE nameReference = (SELECT reference FROM QAGATE_1_MainTable WHERE idPiece = @Last_Id_Piece))							
																									-- Récupération temps de cycle

							SELECT @Prevision = ROUND((CAST(@Bekido_S AS FLOAT)/CAST(@Cycle AS FLOAT)), 0)
																									-- Calcul prevision pièce (CAST ET ROUND pour permettre d'arrondir de manière scientifique)
						END
					ELSE
						BEGIN
							SELECT @Bekido_S = DATEDIFF(second, @DateTime_H, GETDATE())				-- Récupération des secondes entre maintenant et la date + heure

							SELECT @Cycle = tempsCycle 
							FROM QAGATE_1_Cycle 
							WHERE idClient = (SELECT idClient FROM QAGATE_1_Reference WHERE nameReference = (SELECT reference FROM QAGATE_1_MainTable WHERE idPiece = @Last_Id_Piece))
																									-- Récupération temps de cycle

							SELECT @Prevision = ROUND((CAST(@Bekido_S AS FLOAT)/CAST(@Cycle AS FLOAT)),0)			
																									-- Calcul prevision pièce (CAST ET ROUND pour permettre d'arrondir de manière scientifique)	
						END

					SELECT @Piece_Actu = COUNT(idPiece)												-- Récupération du nombres de pièces depuis date + heure (avec sécurité)
					FROM QAGATE_1_MainTable 
					WHERE (((OK = 0 AND (keyenceEtat = 0 AND kogameEtat = 0)) OR (OK = 1 AND (keyenceEtat = 1 OR kogameEtat = 1))) AND (@DateTime_H < timeStamp AND timeStamp < @DateTime_H2) AND currentOF = @OF)

				END

			ELSE	-- Entre 22:00:00 et 06:00:00

				BEGIN

					SELECT @DateTime_H = CAST(@Date_H AS DATETIME) + CAST('22:00:00' AS DATETIME)	-- Ajout de l'heure 22:00:00 à cette date
					SELECT @DateTime_H2 = CAST(CAST(DATEADD(HOUR,+2,GETDATE()) AS DATE) AS DATETIME) + CAST('06:00:00' AS DATETIME) -- Ajout de l'heure 06:00:00 à cette date + 1 jour

					SELECT @OF = currentOF 
					FROM QAGATE_1_MainTable 
					WHERE idPiece = @Last_Id_Piece													-- Numéro d'OF

					IF((SELECT idClient FROM QAGATE_1_Reference INNER JOIN QAGATE_1_MainTable ON nameReference = reference WHERE idPiece = @First_Id_Piece) != (SELECT idClient FROM QAGATE_1_Reference INNER JOIN QAGATE_1_MainTable ON nameReference = reference WHERE idPiece = @Last_Id_Piece))
						BEGIN																		-- Vérifie si la référence de la pièce juste après 06:00:00 et la dernière sont identiques
																									-- Si pas, alors faire ceci

							SELECT @Bekido_S = DATEDIFF(second, (SELECT TOP(1) timeStamp FROM QAGATE_1_MainTable WHERE currentOF = @OF ORDER BY timeStamp ASC), GETDATE())

							SELECT @Cycle = tempsCycle 
							FROM QAGATE_1_Cycle 
							WHERE idClient = (SELECT idClient FROM QAGATE_1_Reference WHERE nameReference = (SELECT reference FROM QAGATE_1_MainTable WHERE idPiece = @Last_Id_Piece))							
																									-- Récupération temps de cycle

							SELECT @Prevision = ROUND((CAST(@Bekido_S AS FLOAT)/CAST(@Cycle AS FLOAT)), 0)
																									-- Calcul prevision pièce (CAST ET ROUND pour permettre d'arrondir de manière scientifique)
						END
					ELSE
						BEGIN
							SELECT @Bekido_S = DATEDIFF(second, @DateTime_H, GETDATE())				-- Récupération des secondes entre maintenant et la date + heure

							SELECT @Cycle = tempsCycle 
							FROM QAGATE_1_Cycle 
							WHERE idClient = (SELECT idClient FROM QAGATE_1_Reference WHERE nameReference = (SELECT reference FROM QAGATE_1_MainTable WHERE idPiece = @Last_Id_Piece))
																									-- Récupération temps de cycle

							SELECT @Prevision = ROUND((CAST(@Bekido_S AS FLOAT)/CAST(@Cycle AS FLOAT)),0)
																									-- Calcul prevision pièce (CAST ET ROUND pour permettre d'arrondir de manière scientifique)
			
						END

					SELECT @Piece_Actu = COUNT(idPiece)												-- Récupération du nombres de pièces depuis date + heure (avec sécurité)
					FROM QAGATE_1_MainTable 
					WHERE (((OK = 0 AND (keyenceEtat = 0 AND kogameEtat = 0)) OR (OK = 1 AND (keyenceEtat = 1 OR kogameEtat = 1))) AND (@DateTime_H < timeStamp AND timeStamp < @DateTime_H2) AND currentOF = @OF) 

				END

			IF(@Prevision  > 0)																		-- Condition pour éviter de diviser par 0
				SELECT @Bekido = ROUND((CAST(@Piece_Actu AS FLOAT)*100)/CAST(@Prevision AS FLOAT), 0)
			ELSE																					-- Calcul Bekido équipe
				SELECT @Bekido = 0

			SELECT @Bekido AS 'Bekido'																-- Affichage de la valeur de sortie procédure

		END
END