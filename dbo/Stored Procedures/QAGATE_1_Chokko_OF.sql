-- =============================================
-- Author: <Minne Charly>
-- Create date: <31/10/2019>
-- Update: <12/11/2019>
-- Description:	< Ce programme permet de calculer le Chokko d'un OF.>
-- =============================================

-- VALIDER --

-- VALEUR DE SORTIE EN SMALLINT --

CREATE PROCEDURE [dbo].[QAGATE_1_Chokko_OF]
AS

	SET NOCOUNT ON

	DECLARE 
			@Chokko SMALLINT,																		-- Chokko du jour en pourcent
			@Val_OK INT,																			-- Ex : Nbr pièce OK entre 06:00:00 08/10/19 et 04:42:16 09/10/19
			@Val_NOK INT,																			-- Ex : Nbr pièce NOK entre 06:00:00 08/10/19 et 04:42:16 09/10/19
			@Last_Id_Piece INT,																		-- Numéro d'OF de la dernière pièce
			@OF VARCHAR(10)																			-- OF Actuel

BEGIN

	SELECT @Last_Id_Piece = MAX(Id_Piece) FROM QAGATE_1_MainTable									-- Récupération de l'Id e la dernière pièce

	SELECT @OF = Current_OF FROM QAGATE_1_MainTable WHERE Id_Piece = @Last_Id_Piece					-- Récupération du code du dernier OF

	SELECT @Val_OK = COUNT(Id_Piece)																-- Récupération du nombres de pièces OK depuis date + heure (avec sécurité) 
	FROM QAGATE_1_MainTable 
	WHERE ((OK = 0 AND (Keyence_Etat = 0 AND Kogame_Etat = 0)) AND Current_OF = @OF)

	SELECT @Val_NOK = COUNT(Id_Piece)																-- Récupération du nombres de pièces NOK depuis date + heure (avec sécurité)  
	FROM QAGATE_1_MainTable 
	WHERE ((OK = 1 AND (Keyence_Etat = 1 OR Kogame_Etat = 1)) AND Current_OF = @OF)

	IF(@Val_OK > 0 OR @Val_NOK > 0)																	-- Condition pour éviter de diviser par 0
		SELECT @Chokko = ROUND((@Val_OK*100)/(@Val_OK + @Val_NOK), 0)								-- Calcul Chokko équipe
	ELSE
		SELECT @Chokko = 0

	SELECT @Chokko AS 'Chokko'																		-- Affichage de la valeur de sortie procédure
END