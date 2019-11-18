-- =============================================
-- Author: <Minne Charly>
-- Create date: <05/11/2019>
-- Update : <12/11/2019>
-- Description:	< Ce programme permet d'obtenir le nombre d'arrêt d'un OF. >
-- =============================================

-- VALIDER --

CREATE PROCEDURE [dbo].[QAGATE_1_Event_Count_OF]
AS
	SET NOCOUNT ON;
	DECLARE 
			@Date_H DATE,																			-- Date avec 6h de moins que la date du jour
			@DateTime_H DATETIME,																	-- Date avec 6h de moins que la date du jour + heure fixe
			@Last_Id_Piece INT,																		-- Numéro d'OF de la dernière pièce
			@OF VARCHAR(10)																			-- OF Actuel

BEGIN

	SELECT @Date_H = CAST(DATEADD(HOUR,-6,GETDATE()) AS DATE)										-- Date actuelle -6h

	SELECT @DateTime_H = CAST(@Date_H AS DATETIME) + CAST('06:00:00' AS DATETIME)					-- Ajout de l'heure 06:00:00 à cette date

	SELECT @Last_Id_Piece = MAX(idPiece) 
	FROM QAGATE_1_MainTable																			-- Récupération de l'id e la dernière pièce

	SELECT @OF = currentOF 
	FROM QAGATE_1_MainTable 
	WHERE idPiece = @Last_Id_Piece																	-- Récupération du code du dernier OF

	SELECT COUNT(idEvent) AS 'Arret'																-- Récupération du nombres d'arret de l'OF
	FROM QAGATE_1_EventData 
	WHERE (currentOF = @OF)				 

END