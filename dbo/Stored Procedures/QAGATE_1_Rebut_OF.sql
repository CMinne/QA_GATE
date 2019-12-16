-- =============================================
-- Author: <Minne Charly>
-- Create date: <10/10/2019>
-- Update : <12/11/2019>
-- Description:	< Ce programme permet le pourcentage et le nombre des rebuts Keyence et Kogame par OF. >
-- =============================================

-- VALIDER --

CREATE PROCEDURE [dbo].[QAGATE_1_Rebut_OF]

AS
	DECLARE 
			@Last_Id_Piece INT,																		-- Numéro d'id de la dernière pièce
			@Last_OF VARCHAR(10),																	-- Numéro d'OF de la dernière pièce
			@Pourcent_Key SMALLINT,																	-- Pourcentage de pièce mauvaise Keyence 
			@Pourcent_Kog SMALLINT,																	-- Pourcentage de pièce mauvaise Kogame
			@Rebut_Tot INT,																			-- Ex : Nbr de rebut entre 06:00:00 08/10/19 et 04:42:16 09/10/19
			@Rebut_Key INT,																			-- Ex : Nbr de rebut keyence entre 06:00:00 08/10/19 et 04:42:16 09/10/19
			@Rebut_Kog INT																			-- Ex : Nbr de rebut kogame entre 06:00:00 08/10/19 et 04:42:16 09/10/19
			

BEGIN

	SELECT @Last_Id_Piece = MAX(idPiece) 
	FROM QAGATE_1_MainTable																			-- Récupération de l'Id de la dernière pièce

	SELECT @Last_OF = currentOF 
	FROM QAGATE_1_MainTable 
	WHERE idPiece = @Last_Id_Piece																	-- Récupération du code du dernier OF

	SELECT @Rebut_Tot = COUNT(idPiece)																-- Récupération du nombres de rebut depuis date + heure (avec sécurité)  
	FROM QAGATE_1_MainTable
	WHERE ((OK = 1 AND (keyenceEtat = 1 OR kogameEtat = 1)) AND currentOF = @Last_OF)

	SELECT @Rebut_Key = COUNT(idPiece)																-- Récupération du nombres de rebut keyence depuis date + heure (avec sécurité)  
	FROM QAGATE_1_MainTable		
	WHERE ((OK = 1 AND (keyenceEtat = 1 AND kogameEtat = 0)) AND currentOF = @Last_OF)

	SELECT @Rebut_Kog = COUNT(idPiece)																-- Récupération du nombres de rebut kogame depuis date + heure (avec sécurité)  
	FROM QAGATE_1_MainTable 
	WHERE ((OK = 1 AND (keyenceEtat = 0 AND kogameEtat = 1)) AND currentOF = @Last_OF)
	
	IF(@Rebut_Key = 0 AND @Rebut_Kog = 0)															-- Condition pour éviter une division par 0
		BEGIN
			SET @Pourcent_Key = 0
			SET @Pourcent_Kog = 0
		END
	ELSE
		BEGIN
			SET @Pourcent_Key = ROUND((CAST(@Rebut_Key AS DECIMAL(5,1))*100)/(CAST(@Rebut_Key AS DECIMAL(5,1))+ CAST(@Rebut_Kog AS DECIMAL(5,1))), 0)						
																											-- Calcul du pourcentage de rebut Keyence
			SET @Pourcent_Kog = ROUND((CAST(@Rebut_Kog AS DECIMAL(5,1))*100)/(CAST(@Rebut_Key AS DECIMAL(5,1))+ CAST(@Rebut_Kog AS DECIMAL(5,1))), 0)							
																											-- Calcul du pourcentage de rebut Kogame
		END

	SELECT @Rebut_Tot AS 'Total', @Rebut_Key AS 'Keyence', @Pourcent_Key AS 'PKeyence', @Rebut_Kog AS 'Kogame', @Pourcent_Kog AS 'PKogame'								
																									-- Affichage des valeurs de sortie procédure

END