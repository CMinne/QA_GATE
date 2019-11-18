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
			@Rebut_Tot INT,																			-- Ex : Nbr de rebut entre 06:00:00 08/10/19 et 04:42:16 09/10/19
			@Rebut_Key INT,																			-- Ex : Nbr de rebut keyence entre 06:00:00 08/10/19 et 04:42:16 09/10/19
			@Rebut_Kog INT,																			-- Ex : Nbr de rebut kogame entre 06:00:00 08/10/19 et 04:42:16 09/10/19
			@Pourcent_Key SMALLINT,																	-- Pourcentage de pièce mauvaise Keyence 
			@Pourcent_Kog SMALLINT																	-- Pourcentage de pièce mauvaise Kogame

BEGIN

	SELECT @Last_Id_Piece = MAX(Id_Piece) 
	FROM QAGATE_1_MainTable																			-- Récupération de l'Id de la dernière pièce

	SELECT @Last_OF = Current_OF 
	FROM QAGATE_1_MainTable 
	WHERE Id_Piece = @Last_Id_Piece																	-- Récupération du code du dernier OF

	SELECT @Rebut_Tot = COUNT(Id_Piece)																-- Récupération du nombres de rebut depuis date + heure (avec sécurité)  
	FROM QAGATE_1_MainTable
	WHERE ((OK = 1 AND (Keyence_Etat = 1 OR Kogame_Etat = 1)) AND Current_OF = @Last_OF)

	SELECT @Rebut_Key = COUNT(Id_Piece)																-- Récupération du nombres de rebut keyence depuis date + heure (avec sécurité)  
	FROM QAGATE_1_MainTable		
	WHERE ((OK = 1 AND (Keyence_Etat = 1 AND Kogame_Etat = 0)) AND Current_OF = @Last_OF)

	SELECT @Rebut_Kog = COUNT(Id_Piece)																-- Récupération du nombres de rebut kogame depuis date + heure (avec sécurité)  
	FROM QAGATE_1_MainTable 
	WHERE ((OK = 1 AND (Keyence_Etat = 0 AND Kogame_Etat = 1)) AND Current_OF = @Last_OF)
	
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

	SELECT @Rebut_Tot AS 'Total', @Rebut_Key AS 'Keyence', @Pourcent_Key AS 'PKeyence', @Rebut_Kog AS 'Kogame', @Pourcent_Kog AS 'PKogame'								
																									-- Affichage des valeurs de sortie procédure

END