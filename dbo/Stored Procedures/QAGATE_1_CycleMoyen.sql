-- =============================================
-- Author: <Minne Charly>
-- Create date: <29/11/2019>
-- Update: <05/12/2019>
-- Description:	< Ce programme permet de calculer la moyenne des temps de cycles sur les 200 dernières pièces. >

-- Commentaire: Ce programme utilise les vues QAGATE_1_ViewCycleUE21 et QAGATE_1_ViewCycleUE24 qui séléctionnent les 200 dernières pièces
--				Le temps de cycle est calculé pour tout type de pièce, uniquement pendant le mode run de la QA GATE

-- =============================================

-- VALIDER --

CREATE PROCEDURE [dbo].[QAGATE_1_CycleMoyen]
AS
	SET NOCOUNT ON
	DECLARE @Code SMALLINT,																			-- Code d'erreur
			@Cycle DECIMAL(5,1),																	-- Temps de cycle temporaire pour tri
			@CycleUE21 DECIMAL(5,1),																-- Temps de cycle moyen UE21 (200 dernière pièce)
			@CycleUE24 DECIMAL(5,1),																-- Temps de cycle moyen UE24 (200 dernière pièce)
			@DateId DATETIME,																		-- Date de la dernière pièce
			@DatePrev_Id DATETIME,																	-- Date de la précédente pièce
			@EventEtat TINYINT,																		-- Flag d'état pour ne pas compter le temps entre deux pièces si il y a eu un arrêt
			@Flag BIT,																				-- Flag de passage d'état
			@Id INT,																				-- Numéro d'id de la dernière pièce
			@NbrRows INT,																			-- Nombre de ligne du curseur
			@Nbr_Piece INT,																			-- Nombre de pièce pour l'OF
			@Prev_Id INT,																			-- Numéro d'id de la précédente pièce
			@Row TINYINT,																			-- Flag pour faire une fois pour UE21 et une fois pour UE24
			@SumCycle INT																			-- Somme temps cycle
			
BEGIN
	SET @Row = 2																					-- Set à deux car deux ref client (UE21 UE24)
	SET @Flag = 1

	WHILE(@Row > 0)
	BEGIN
		SET @Nbr_Piece = 0
		SET @SumCycle = 0

		IF (@Row = 2)																				-- Si oui, alors calcul pour UE21
			BEGIN
				DECLARE curseur_id CURSOR STATIC													-- Création d'un curseur pour le calcul du temps de cycle
				FOR SELECT idPiece
					FROM QAGATE_1_ViewCycleUE21
			END

		ELSE
			BEGIN
				DECLARE curseur_id CURSOR STATIC													-- Création d'un curseur pour le calcul du temps de cycle
				FOR SELECT idPiece
					FROM QAGATE_1_ViewCycleUE24
			END
			
	
		OPEN curseur_id																				-- Ouverture du curseur
		SET @NbrRows = @@CURSOR_ROWS																-- Compte le nombre de lignes (rows)

		SET @Nbr_Piece = @NbrRows																	-- Le nombre de ligne du curseur est le nombre de pièce, utile pour le calcul du temps de cycle moyen

		FETCH NEXT FROM curseur_id INTO @Id															-- Prends l'id de la pièce la plus récente et le met dans @Id

		WHILE(@NbrRows > 0)
			BEGIN
			
				FETCH NEXT FROM curseur_id INTO @Prev_Id											-- Prends l'id de la pièce précédente et le met dans @Prev_Id

				SELECT @DateId = timeStamp 
				FROM QAGATE_1_MainTable 
				WHERE idPiece = @Id																	-- Récupération de l'horodatage de @Id

				SELECT @DatePrev_Id = timeStamp 
				FROM QAGATE_1_MainTable 
				WHERE idPiece = @Prev_Id															-- Récupération de l'horodatage de @Prev_Id

				SELECT TOP(1) @EventEtat = Etat, @Code = code										-- Détermination de l'état du système entre les deux contrôles des pièces
				FROM QAGATE_1_EventData 
				WHERE (timeStamp >= @DatePrev_Id AND timeStamp < @DateId) 
				ORDER BY timeStamp DESC

				IF (@EventEtat = 3 AND @Code = 0)													-- Si QA Gate Repasse en ON, flag = 1
					SET @Flag = 1
				ELSE IF (@EventEtat = 0 OR @EventEtat = 1 OR @EventEtat = 2)											-- Si GA Gate passe en setup ou OFF, Flag = 0
					SET @Flag = 0

				--SELECT @EventEtat AS 'Etat', @Code AS 'Code', @DatePrev_Id AS 'Date Prev', @Id AS 'Date' 
				IF((NOT(@EventEtat = 0 OR @EventEtat = 1 OR @EventEtat = 2 OR (@EventEtat = 3 AND @Code = 0)) OR @EventEtat IS NULL) AND @Flag = 1)
																									-- Si il y a pas eu d'arrêt ni de setup, on fait le script
					BEGIN
						SET @SumCycle += (SELECT(DATEDIFF (SECOND, t1.timeStamp, t2.timeStamp))
											FROM QAGATE_1_MainTable t1 CROSS JOIN
												QAGATE_1_MainTable t2
											WHERE t1.idPiece = @Prev_Id AND t2.idPiece = @Id)		-- Jointure croisée pour soustraire les temps des deux pièces
						--SELECT @SumCycle
					END
					
				SET @EventEtat = NULL
				SET @Code = NULL
				SET @NbrRows -= 1																	-- Décrémentation
				SET @Id = @Prev_Id																	-- On déplace le pointeurs

				CONTINUE
			
			END

		BEGIN TRY																					-- Gestion erreur overflow tems de cycle  
    
			SET @Cycle = CAST(@SumCycle/CAST(@Nbr_Piece AS DECIMAL(5,1)) AS DECIMAL(5,1))			-- Calcul du temps de cycle moyen (Temps total/Nombre de pièce)

			IF(@Row = 2)																			-- Si on calculait pour UE21
				SET @CycleUE21 = @Cycle
			ELSE																					-- Si pas
				SET @CycleUE24 = @Cycle 

		END TRY  
		BEGIN CATCH																					-- Si overflow, on met des valeurs par défaut
		
			IF(@Row = 2)
				SET @CycleUE21 = 1
			ELSE
				SET @CycleUE24 = 1
			 
		END CATCH; 

		CLOSE curseur_id																			-- Fermeture du curseur
		DEALLOCATE curseur_id
		SET @Row -= 1																				-- Décrémentation

		CONTINUE																					-- Retourne au début du WHILE
	END

	SELECT @CycleUE21 AS 'UE21', @CycleUE24 AS 'UE24'																	-- Selection des temps de cycle pour la sortie

END