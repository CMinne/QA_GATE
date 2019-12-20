-- =============================================
-- Author: <Minne Charly>
-- Create date: <04/12/2019>
-- Update: <12/12/2019>
-- Description:	< Ce programme permet de récupérer les valeurs venant de la QA Gate. >
-- =============================================

-- VALIDER --

CREATE PROCEDURE [dbo].[QAGATE_1_ExtractionQG](
	@OF VARCHAR(10),
	@Reference VARCHAR(15)
)
AS

	SET NOCOUNT ON																					-- Obligatoire

	DECLARE 
			
			@Id INT,																				-- Id actuel
			@Id_prev INT,																			-- Id précédente
			@Id_prevF INT,																			-- Sauvegarde ID précédente 
			@NbrRows INT,																			-- Nombre de ligne du curseur
			@Debut_Date DATE,																		-- Suivi de la date
			@Time1 DATETIME,																		-- Temps 1 pour calcul de la durée entre 2 event
			@Time2 DATETIME,																		-- Temps 2 pour calcul de la durée entre 2 event
			@Time_Run INT,																			-- Somme du temps de run
			@Time_Stop INT,																			-- Somme du temps de stop
			@Total INT,																				-- Somme des pièces passées par la QA Gate
			@Keyence INT,																			-- Somme des NG Keyence 
			@Kogame INT,																			-- Somme des NG Kogame 
			@Flag BIT																				-- Flag pour le changement de jour

	SET @Time_Run = 0
	SET @Time_Stop = 0

	SET @Total = 0
	SET @Keyence = 0
	SET @Kogame = 0

	CREATE TABLE #temp_table																		-- Table résumant toutes les données par jour
	(
		currentOF VARCHAR(10),																		-- OF
		reference VARCHAR(15),																		-- Reference
		dateOF DATE,																				-- Dates d'ouverture de l'OF
		run INT,																					-- Temps de fonctionnement (Par addition)
		arret INT,																					-- Temps d'arrêt (Par addition)
		pieceBonne INT,																				-- Nombre de pièce contrôlée (Par addition)
		keyence INT,																				-- Nombre de NG Keyence (Par addition)
		kogame INT																					-- Nombre de NG Kogame (Par addition)
	)
BEGIN
	DECLARE curseur_event CURSOR STATIC																-- Création d'un curseur pour l'obtention des références
		FOR SELECT idEvent																			-- Récupère tous les évènements de l'OF 
			FROM QAGATE_1_EventData 
			WHERE currentOF = @OF 
			ORDER BY timeStamp ASC

	OPEN curseur_event																				-- Ouverture du curseur
	SET @NbrRows = @@CURSOR_ROWS																	-- Compte le nombre de lignes (rows)

	FETCH NEXT FROM curseur_event INTO @Id_prev														-- Copie l'id de l'event de la première ligne dans @Id_prev


	SELECT @Debut_Date = CAST(timeStamp AS DATE)													-- Date du début de l'OF (Pour savoir quand commencer)
	FROM QAGATE_1_EventData 
	WHERE idEvent = @Id_prev	

	WHILE(@NbrRows > 0)																				-- Boucle % au curseur event pour récupérer les données  
		BEGIN
			FETCH NEXT FROM curseur_event INTO @Id													-- Copie l'id de l'event de la première ligne dans @Id_prev

			IF(@Flag = 1)																			-- Si il y a un changement de jour, alors faire le script
				BEGIN
					
					SELECT @Time2 = timeStamp 
					FROM QAGATE_1_EventData 
					WHERE idEvent = @Id_prev													-- Détermine l'heure (+ date accessoirement) du premier évènement du jour

					IF((SELECT Etat FROM QAGATE_1_EventData WHERE idEvent = @Id_prevF) = 3)			-- Vérifie si on est en run
						BEGIN
							
							SET @Time_Run += DATEDIFF(SECOND, DATEADD(HOUR, 6, CAST(@Debut_Date AS DATETIME)), @Time2)
																									-- Calcul du temps entre 06:00:00 et le premier évènement du jour
							--SELECT @Time2 AS 'TIME RUN', @Time_Run AS 'RUN TOT', @Id, @Id_prev
							--SELECT '1 RUN'
						END

					ELSE																			-- Si on est en stop ou setup
						BEGIN

							SET @Time_Stop += DATEDIFF(SECOND, DATEADD(HOUR, 6, CAST(@Debut_Date AS DATETIME)), @Time2)
																									-- Calcul du temps entre 06:00:00 et le premier évènement du jour
							--SELECT '1 STOP'
						END
					IF (@Id = @Id_prev)																-- Si on est au dernier évènement
						BREAK																		-- On sort de la boucle WHILE
					SET @Flag = 0																	-- Retour du flag à 0 pour valider le changement de jour
				END

			IF((SELECT timeStamp FROM QAGATE_1_EventData WHERE idEvent = @Id) < DATEADD(HOUR, 30, CAST(@Debut_Date AS DATETIME)))
				BEGIN																				-- Regarde si le prochain évènement est dans le même jour (06:00:00 et 06:00:00 le lendemain)

					SELECT @Time1 = timeStamp 
					FROM QAGATE_1_EventData 
					WHERE idEvent = @Id_prev														-- Détermine l'heure (+ date accessoirement) de l'évènement précédent

					SELECT @Time2 = timeStamp 
					FROM QAGATE_1_EventData 
					WHERE idEvent = @Id																-- Détermine l'heure (+ date accessoirement) de l'évènement actuel

					IF((SELECT Etat FROM QAGATE_1_EventData WHERE idEvent = @Id_prev) = 3)			-- Vérifie si on est en run 
						BEGIN

							SET @Time_Run += DATEDIFF(SECOND, @Time1, @Time2)						-- Calcul du temps entre l'évènement précédent et l'évènement actuel
							--SELECT @Time1 AS 'TIME RUN', @Time2 AS 'TIME RUN', @Time_Run AS 'RUN TOT', @Id, @Id_prev
							--SELECT '3 RUN'
						END

					ELSE																			-- Si on est en stop ou setup
						BEGIN

							SET @Time_Stop += DATEDIFF(SECOND, @Time1, @Time2)						-- Calcul du temps entre l'évènement précédent et l'évènement actuel
							--SELECT '3 STOP'
						END
					IF (@Id = @Id_prev)																-- Si on est au dernier évènement
						BREAK																		-- On sort de la boucle WHILE
				END

			ELSE																					-- Si pas, alors l'évènement est dans le jour prochain
				BEGIN

					SELECT @Time1 = timeStamp FROM QAGATE_1_EventData WHERE idEvent = @Id_prev		-- Détermine l'heure (+ date accessoirement) de l'évènement précédent 

					IF((SELECT Etat FROM QAGATE_1_EventData WHERE idEvent = @Id_prev) = 3)			-- Vérifie si on est en run 
						BEGIN
							
							SET @Time_Run += DATEDIFF(SECOND, @Time1, DATEADD(HOUR, 30, CAST(@Debut_Date AS DATETIME)))
																									-- Calcul du temps entre l'évènement précédent et 06:00:00 le lendemain
							--SELECT @Time1 AS 'TIME RUN', @Time_Run AS 'RUN TOT', @Id, @Id_prev
							--SELECT '4 RUN'
						END

					ELSE																			-- Si on est en stop ou setup
						BEGIN

							SET @Time_Stop += DATEDIFF(SECOND, @Time1, DATEADD(HOUR, 30, CAST(@Debut_Date AS DATETIME)))
																									-- Calcul du temps entre l'évènement précédent et 06:00:00 le lendemain
							--SELECT '4 STOP'
						END
					SET @Flag = 1																	-- Flag de changement de jour

					SET @Total += (SELECT COUNT(idPiece)											-- Additionne le nombre de pièce contrôlée pour le jour en cours
								   FROM QAGATE_1_MainTable 
								   WHERE currentOF = @OF 
								   AND timeStamp >= DATEADD(HOUR, 6, CAST(@Debut_Date AS DATETIME)) 
								   AND timeStamp < DATEADD(HOUR, 30, CAST(@Debut_Date AS DATETIME)) AND OK = 0)

					SET @Keyence += (SELECT COUNT(idPiece) 											-- Additionne le nombre de NG Keyence pour le jour en cours
									 FROM QAGATE_1_MainTable 
									 WHERE currentOF = @OF 
									 AND timeStamp >= DATEADD(HOUR, 6, CAST(@Debut_Date AS DATETIME)) 
									 AND timeStamp < DATEADD(HOUR, 30, CAST(@Debut_Date AS DATETIME)) AND keyenceEtat = 1 AND OK = 1)

					SET @Kogame += (SELECT COUNT(idPiece)											-- Additionne le nombre de NG Kogame pour le jour en cours 
									FROM QAGATE_1_MainTable 
									WHERE currentOF = @OF 
									AND timeStamp >= DATEADD(HOUR, 6, CAST(@Debut_Date AS DATETIME)) 
									AND timeStamp < DATEADD(HOUR, 30, CAST(@Debut_Date AS DATETIME)) AND kogameEtat = 1 AND OK = 1)

					INSERT INTO #temp_table (currentOF, reference , dateOF     , run      , arret     , pieceBonne, keyence , kogame )
						   VALUES			(@OF	  , @Reference, @Debut_Date, (@Time_Run/60), (@Time_Stop/60), @Total    , @Keyence, @Kogame)
																									-- Insert les données dans la table temporaire
					SELECT @Debut_Date = CAST(timeStamp AS DATE) 
					FROM QAGATE_1_EventData 
					WHERE idEvent = @Id																-- Changement de date (Suivante)
				END

			--SELECT @NbrRows AS 'ROW'
			SET @Id_prevF = @Id_prev																-- Déplacement des id pour le curseur
			SET @Id_prev = @Id																		-- Déplacement des id pour le curseur
			SET @NbrRows -= 1																		-- Décrémentation
			--SELECT @Debut_Date
			CONTINUE																				-- Retour au FETCH
		END

	IF((SELECT Etat FROM QAGATE_1_EventData WHERE idEvent = @Id_prev) = 3)
		BEGIN
			SELECT @Time1 = timeStamp FROM QAGATE_1_EventData WHERE idEvent = @Id_prev
			SELECT TOP(1) @Time2 = timeStamp FROM QAGATE_1_MainTable WHERE currentOF = @OF ORDER BY timeStamp DESC
			IF(@Time2 > @Time1)
				SET @Time_Run += DATEDIFF(SECOND, @Time1, @Time2)
				--SELECT @Time1 AS 'TIME RUN', @Time_Run AS 'RUN TOT', @Id, @Id_prev
			--SELECT 'FIN RUN'
		END

	ELSE
		BEGIN
			SELECT @Time1 = timeStamp FROM QAGATE_1_EventData WHERE idEvent = @Id_prev
			SELECT TOP(1) @Time2 = timeStamp FROM QAGATE_1_MainTable WHERE currentOF = @OF ORDER BY timeStamp DESC
			IF(@Time2 > @Time1)
				SET @Time_Stop += DATEDIFF(SECOND, @Time1, @Time2)
			--SELECT 'FIN STOP'
		END

	SET @Total += (SELECT COUNT(idPiece)															-- Additionne le nombre de pièce contrôlée pour le jour en cours
				   FROM QAGATE_1_MainTable 
				   WHERE currentOF = @OF 
				   AND timeStamp >= DATEADD(HOUR, 6, CAST(@Debut_Date AS DATETIME)) 
				   AND timeStamp < DATEADD(HOUR, 30, CAST(@Debut_Date AS DATETIME)) AND OK = 0)

	SET @Keyence += (SELECT COUNT(idPiece) 															-- Additionne le nombre de NG Keyence pour le jour en cours
					 FROM QAGATE_1_MainTable 
					 WHERE currentOF = @OF 
					 AND timeStamp >= DATEADD(HOUR, 6, CAST(@Debut_Date AS DATETIME)) 
					 AND timeStamp < DATEADD(HOUR, 30, CAST(@Debut_Date AS DATETIME)) AND keyenceEtat = 1 AND OK = 1)

	SET @Kogame += (SELECT COUNT(idPiece)															-- Additionne le nombre de NG Kogame pour le jour en cours 
					FROM QAGATE_1_MainTable 
					WHERE currentOF = @OF 
					AND timeStamp >= DATEADD(HOUR, 6, CAST(@Debut_Date AS DATETIME)) 
					AND timeStamp < DATEADD(HOUR, 30, CAST(@Debut_Date AS DATETIME)) AND kogameEtat = 1 AND OK = 1)

	INSERT INTO #temp_table (currentOF, reference , dateOF     , run      , arret     , pieceBonne, keyence , kogame )
			VALUES			(@OF	  , @Reference, @Debut_Date, (@Time_Run/60), (@Time_Stop/60), @Total    , @Keyence, @Kogame)
																									-- Insert les données dans la table temporaire

	CLOSE curseur_event																				-- Fermeture du curseur
	DEALLOCATE curseur_event																		-- Suppression du curseur

	SELECT currentOF, reference, FORMAT (dateOF, 'dd/MM/yy') AS 'dateJour', run, arret, pieceBonne, keyence , kogame 
	FROM #temp_table																				-- Valeurs de sortie
	DROP TABLE #temp_table
END