-- =============================================
-- Author: <Minne Charly>
-- Create date: <10/10/2019>
-- Update : <26/11/2019>
-- Description:	< Ce programme permet d'obtenir les numéros d'ârret + l'heure entre 06:00:00 et 06:00:00 le lendemain. Ne se base pas sur le numéro de l'OF. >
-- =============================================

-- VALIDER --

CREATE PROCEDURE [dbo].[QAGATE_1_Event_Jour]
AS
	SET NOCOUNT ON;
	DECLARE 
			@Date_H DATE,																			-- Date avec 6h de moins que la date du jour
			@DateTime_H DATETIME,																	-- Date avec 6h de moins que la date du jour + heure fixe
			@Id_Event INT,
			@Last_Id_Piece INT,																		-- Numéro d'OF de la dernière pièce
			@OF VARCHAR(10)																			-- Numéro de l'OF

BEGIN

	SELECT @Date_H = CAST(DATEADD(HOUR,-6,GETDATE()) AS DATE)										-- Date actuelle -6h

	SELECT @DateTime_H = CAST(@Date_H AS DATETIME) + CAST('06:00:00' AS DATETIME)					-- Ajout de l'heure 06:00:00 à cette date

	SELECT @Last_Id_Piece = MAX(idPiece) 
	FROM QAGATE_1_MainTable																			-- Récupération de l'id de la dernière pièce

	SELECT @OF = currentOF 
	FROM QAGATE_1_MainTable 
	WHERE idPiece = @Last_Id_Piece																	-- Numéro d'OF

	SET @Id_Event =(SELECT TOP(1) idEvent															-- Copie de l'id du dernier évènement d'avant 06:00:00 de la journée précédente
					FROM QAGATE_1_EventData 
					WHERE timeStamp < @DateTime_H
					ORDER BY timeStamp DESC)

	SELECT currentOF, code, etat, timeStamp															-- Récupération des arrets + heure depuis date + heure
	FROM QAGATE_1_EventData 
	WHERE idEvent >= @Id_Event				 

END