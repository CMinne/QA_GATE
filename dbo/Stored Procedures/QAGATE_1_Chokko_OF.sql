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
			@Last_Id_Piece INT,																		-- Numéro d'OF de la dernière pièce
			@OF VARCHAR(10),																		-- OF Actuel
			@Val_OK INT,																			-- Ex : Nbr pièce OK entre 06:00:00 08/10/19 et 04:42:16 09/10/19
			@Val_NOK INT																			-- Ex : Nbr pièce NOK entre 06:00:00 08/10/19 et 04:42:16 09/10/19

BEGIN

	SELECT @Last_Id_Piece = MAX(idPiece) FROM QAGATE_1_MainTable									-- Récupération de l'Id e la dernière pièce

	SELECT @OF = currentOF FROM QAGATE_1_MainTable WHERE IdPiece = @Last_Id_Piece					-- Récupération du code du dernier OF

	SELECT @Val_OK = COUNT(idPiece)																	-- Récupération du nombres de pièces OK depuis date + heure (avec sécurité) 
	FROM QAGATE_1_MainTable 
	WHERE ((OK = 0 AND (keyenceEtat = 0 AND kogameEtat = 0)) AND currentOF = @OF)

	SELECT @Val_NOK = COUNT(idPiece)																-- Récupération du nombres de pièces NOK depuis date + heure (avec sécurité)  
	FROM QAGATE_1_MainTable 
	WHERE ((OK = 1 AND (keyenceEtat = 1 OR kogameEtat = 1)) AND currentOF = @OF)

	IF(@Val_OK > 0 OR @Val_NOK > 0)																	-- Condition pour éviter de diviser par 0
		SELECT @Chokko = ROUND((@Val_OK*100)/(@Val_OK + @Val_NOK), 0)								-- Calcul Chokko équipe
	ELSE
		SELECT @Chokko = 0

	SELECT @Chokko AS 'Chokko'																		-- Affichage de la valeur de sortie procédure
END