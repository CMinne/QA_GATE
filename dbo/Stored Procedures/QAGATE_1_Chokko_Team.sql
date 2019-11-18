-- =============================================
-- Author: <Minne Charly>
-- Create date: <31/10/2019>
-- Update: <13/11/2019>
-- Description:	< Ce programme permet de calculer le Chokko d'un OF.>
-- =============================================

-- VALIDER --

-- VALEUR DE SORTIE EN SMALLINT --

-- /!\ ATTENTION ALGORITHM WEEK-END PAS ENCORE CODE --

CREATE PROCEDURE [dbo].[QAGATE_1_Chokko_Team]
AS
	DECLARE 
			@Chokko SMALLINT,																		-- Chokko équipe en pourcent
			@Date_H DATE,																			-- Date avec 6h de moins que la date du jour
			@DateTime_H DATETIME,																	-- Date avec 6h de moins que la date du jour + heure fixe
			@DateTime_H2 DATETIME,																	-- Date avec 6h de moins que la date du jour + autre heure fixe
			@Last_Id_Piece INT,																		-- Numéro d'OF de la dernière pièce
			@Numero_Jour INT,																		-- Numéro du jour, permet de différencier week-end et semaine
			@OF VARCHAR(10),																		-- Numéro de l'OF
			@Val_OK INT,																			-- Ex : Nbr pièce OK entre 06:00:00 08/10/19 et 13:23:52 08/10/19
			@Val_NOK INT																			-- Ex : Nbr pièce NOK entre 06:00:00 08/10/19 et 13:23:52 08/10/19

BEGIN

	SELECT @Date_H = CAST(DATEADD(HOUR,-6,GETDATE()) AS DATE)										-- Date actuelle -6h

	SELECT @Last_Id_Piece = MAX(idPiece) 
	FROM QAGATE_1_MainTable																			-- Récupération de l'id de la dernière pièce

	SELECT @OF = currentOF 
	FROM QAGATE_1_MainTable 
	WHERE idPiece = @Last_Id_Piece																	-- Numéro d'OF

-- Pour chaque équipe
	SET @Numero_Jour = DATEPART(DW, GETDATE());														-- Détermine le numéro du jour actuel
	-- Semaine 
	IF(@Numero_Jour != 1 OR @Numero_Jour != 7)														-- Détermine si on est le week-end
		BEGIN
			IF(('06:00:00' <= CAST(GETDATE() AS TIME)) AND (CAST(GETDATE() AS TIME) < '14:00:00'))	-- Détermine si on est entre 06:00:00 et 14:00:00

				BEGIN

					SELECT @DateTime_H = CAST(@Date_H AS DATETIME) + CAST('06:00:00' AS DATETIME)	-- Ajout de l'heure 06:00:00 à cette date
					SELECT @DateTime_H2 = CAST(@Date_H AS DATETIME) + CAST('14:00:00' AS DATETIME)	-- Ajout de l'heure 14:00:00 à cette date

					SELECT @Val_OK = COUNT(idPiece)													-- Récupération du nombres de pièces OK depuis date + heure (avec sécurité)
					FROM QAGATE_1_MainTable 
					WHERE ((OK = 0 AND (keyenceEtat = 0 AND kogameEtat = 0)) AND (@DateTime_H < timeStamp AND timeStamp < @DateTime_H2) AND currentOF = @OF)

					SELECT @Val_NOK = COUNT(idPiece)												-- Récupération du nombres de pièces NOK depuis date + heure (avec sécurité) 
					FROM QAGATE_1_MainTable main 
					WHERE ((OK = 1 AND (keyenceEtat = 1 OR kogameEtat = 1)) AND (@DateTime_H < timeStamp AND timeStamp < @DateTime_H2) AND currentOF = @OF)

					IF(@Val_OK > 0 OR @Val_NOK > 0)													-- Condition pour éviter de diviser par 0
						SELECT @Chokko = (@Val_OK*100)/(@Val_OK + @Val_NOK)							-- Calcul Chokko équipe
					ELSE
						SELECT @Chokko = 0


				END

			ELSE IF(('14:00:00' <= CAST(GETDATE() AS TIME)) AND (CAST(GETDATE() AS TIME) < '22:00:00'))	
																									-- Détermine si on est entre 14:00:00 et 22:00:00
				BEGIN

					SELECT @DateTime_H = CAST(@Date_H AS DATETIME) + CAST('14:00:00' AS DATETIME)	-- Ajout de l'heure 14:00:00 à cette date
					SELECT @DateTime_H2 = CAST(@Date_H AS DATETIME) + CAST('22:00:00' AS DATETIME)	-- Ajout de l'heure 22:00:00 à cette date

					SELECT @Val_OK = COUNT(idPiece)													-- Récupération du nombres de pièces OK depuis date + heure (avec sécurité) 
					FROM QAGATE_1_MainTable 
					WHERE ((OK = 0 AND (keyenceEtat = 0 AND kogameEtat = 0)) AND (@DateTime_H < timeStamp AND timeStamp < @DateTime_H2) AND currentOF = @OF)

					SELECT @Val_NOK = COUNT(idPiece)												-- Récupération du nombres de pièces NOK depuis date + heure (avec sécurité)  
					FROM QAGATE_1_MainTable 
					WHERE ((OK = 1 AND (keyenceEtat = 1 OR kogameEtat = 1)) AND (@DateTime_H < timeStamp AND timeStamp < @DateTime_H2) AND currentOF = @OF)

					IF(@Val_OK > 0 OR @Val_NOK > 0)													-- Condition pour éviter de diviser par 0
						SELECT @Chokko = (@Val_OK*100)/(@Val_OK + @Val_NOK)							-- Calcul Chokko équipe
					ELSE
						SELECT @Chokko = 0

				END

			ELSE	-- Entre 22:00:00 et 06:00:00

				BEGIN

					SELECT @DateTime_H = CAST(@Date_H AS DATETIME) + CAST('22:00:00' AS DATETIME)	-- Ajout de l'heure 22:00:00 à cette date
					SELECT @DateTime_H2 = CAST(CAST(DATEADD(HOUR,+2,GETDATE()) AS DATE) AS DATETIME) + CAST('06:00:00' AS DATETIME) -- Ajout de l'heure 06:00:00 à cette date + 1 jour

					SELECT @Val_OK = COUNT(idPiece)													-- Récupération du nombres de pièces OK depuis date + heure (avec sécurité)  
					FROM QAGATE_1_MainTable 
					WHERE ((OK = 0 AND (keyenceEtat = 0 AND kogameEtat = 0)) AND (@DateTime_H < timeStamp AND timeStamp < @DateTime_H2) AND currentOF = @OF)

					SELECT @Val_NOK = COUNT(idPiece)												-- Récupération du nombres de pièces NOK depuis date + heure (avec sécurité)   
					FROM QAGATE_1_MainTable main 
					WHERE ((OK = 1 AND (keyenceEtat = 1 OR kogameEtat = 1)) AND (@DateTime_H < timeStamp AND timeStamp < @DateTime_H2) AND currentOF = @OF)

					IF(@Val_OK > 0 OR @Val_NOK > 0)													-- Condition pour éviter de diviser par 0
						SELECT @Chokko = (@Val_OK*100)/(@Val_OK + @Val_NOK)							-- Calcul Chokko équipe
					ELSE
						SELECT @Chokko = 0

				END

			SELECT @Chokko AS 'Chokko'																-- Affichage de la valeur de sortie procédure
		END
END