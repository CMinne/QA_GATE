﻿-- =============================================
-- Author: <Minne Charly>
-- Create date: <05/11/2019>
-- Update : <12/11/2019>
-- Description:	< Ce programme permet d'obtenir les numéros d'ârret + l'heure d'un OF. >
-- =============================================

-- VALIDER --

CREATE PROCEDURE [dbo].[QAGATE_1_Event_OF]
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

	SELECT @Last_Id_Piece = MAX(Id_Piece) FROM QAGATE_1_MainTable									-- Récupération de l'id e la dernière pièce

	SELECT @OF = Current_OF FROM QAGATE_1_MainTable WHERE Id_Piece = @Last_Id_Piece					-- Récupération du code du dernier OF

	SELECT Code, CONVERT(TIME(0), Heure_Event) AS Heure_Event										-- Récupération du nombres des arrêts + heure d'un OF
	FROM QAGATE_1_EventData 
	WHERE (Current_OF = @OF)				 

END