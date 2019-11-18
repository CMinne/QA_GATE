-- =============================================
-- Author: <Minne Charly>
-- Create date: <10/10/2019>
-- Update: <12/11/2019>
-- Description:	< Ce programme permet d'obtenir l'avancement d'un OF, ainsi que la date de commencement de cette OF. >
-- =============================================

-- VALIDER --

CREATE PROCEDURE [dbo].[QAGATE_1_Avancement]
AS
	SET NOCOUNT ON

	DECLARE 
			@Last_Id_Piece INT,																		-- Numéro d'id de la dernière pièce
			@Last_OF VARCHAR(10),																	-- Numéro d'OF de la dernière pièce
			@First_Id_Piece INT,																	-- Numéro d'id de la première pièce
			@Nbr_Piece_Actu INT,																	-- Nombre de pièce pour l'OF
			@Nbr_piece INT,																			-- Nombre de pièce totale
			@Avancement DECIMAL(5,1),																-- Avancement en pourcent
			@Valeur_Date_OF VARCHAR(10)																-- VARCHAR pour des questions de mise en page (JJ/MM/AA)
BEGIN

	SELECT @Last_Id_Piece = MAX(Id_Piece) 
	FROM QAGATE_1_MainTable																			-- Récupération de l'Id de la dernière pièce

	SELECT @Last_OF = Current_OF 
	FROM QAGATE_1_MainTable 
	WHERE Id_Piece = @Last_Id_Piece																	-- Récupération du code du dernier OF

	SELECT TOP 1 @Valeur_Date_OF =  CONVERT(VARCHAR, CAST(Heure_Reseau AS DATE) , 3)
	FROM QAGATE_1_MainTable
	WHERE Current_OF = @Last_OF																		-- Récupération de la date (JJ/MM/AA) (mode 3) de la première pièce de l'OF, et l'id de la piece

	SELECT @Nbr_Piece_Actu = COUNT(Id_Piece)
	FROM QAGATE_1_MainTable			
	WHERE (Current_OF = @Last_OF)																	-- Calcul du nombre de pièce actuelle

	SELECT @Nbr_piece = Quantite 
	FROM QAGATE_1_NombrePiece 
	WHERE Id_Client = (SELECT Id_Client FROM QAGATE_1_Reference WHERE Names = (SELECT Reference FROM QAGATE_1_MainTable WHERE Id_Piece = @Last_Id_Piece))
																									-- Récupération du nombre de pièce
	IF (@Nbr_Piece > 0)																				-- Sécurité si Nbr_Piece est négatif (erreur d'encodage)
		SELECT @Avancement = (CAST(@Nbr_Piece_Actu AS DECIMAL(5,1))*100)/@Nbr_Piece					-- Calcul de l'avancement par rapport au nombre de pièce d'un OF
	ELSE
		SELECT @Avancement = 100

	SELECT @Avancement AS 'Avancement', @Valeur_Date_OF AS 'Date'									-- Affichage des valeurs de sortie procédure

END