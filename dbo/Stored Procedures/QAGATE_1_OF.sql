-- =============================================
-- Author: <Minne Charly>
-- Create date: <05/11/2019>
-- Update : <12/11/2019>
-- Description:	< Ce programme permet d'obtenir les numéros d'ârret + l'heure d'un OF. >
-- =============================================

-- VALIDER --

CREATE PROCEDURE [dbo].[QAGATE_1_OF]

AS
	SET NOCOUNT ON

	DECLARE 
			@Last_Id_Piece INT,																		-- ID de la dernière pièce
			@Valeur_OF VARCHAR(10)
BEGIN

	SELECT @Last_Id_Piece = MAX(Id_Piece) 
	FROM QAGATE_1_MainTable																			-- Récupération de l'Id e la dernière pièce

	SELECT @Valeur_OF = Current_OF 
	FROM QAGATE_1_MainTable 
	WHERE Id_Piece = @Last_Id_Piece																	-- Récupération du code du dernière OF

	SELECT @Valeur_OF AS 'OF'																		-- Affichage de la valeur de sortie procédure

END