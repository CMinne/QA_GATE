-- =============================================
-- Author: <Minne Charly>
-- Create date: <20/10/2019>
-- Update: <20/11/2019>
-- Description:	< Ce programme permet d'obtenir l'ensemble des OF présents dans la base de données, ainsi que la date de commencement et de fin de chaque OF. >
-- =============================================

-- VALIDER --

CREATE PROCEDURE [dbo].[QAGATE_1_OFDate](
	@2000 BIT,
	@2100 BIT,
	@3200 BIT,
	@3300 BIT,
	@Debut DATETIME,
	@Fin DATETIME
)AS
	SET NOCOUNT ON

	DECLARE 
			@NbrRows INT,																				-- Avancement en pourcent
			@DateDebut DATETIME,
			@DateFin DATETIME,
			@OF VARCHAR(10),
			@Reference VARCHAR(15)
			

BEGIN

	CREATE TABLE #temp_table (
		currentOF VARCHAR(10),
		reference VARCHAR(15),
		date_Debut DATETIME,
		date_Fin DATETIME
	)

	CREATE TABLE #ref																					-- Table pour le tri par numéro de référence
	(	
		reference VARCHAR(15)
	)

	-- SI NOUVELLE REFERENCE, AJOUTER ICI --
	IF(@2000 = 1)
		INSERT INTO #ref (reference) VALUES ('490035-2000')												-- UE21
	IF(@2100 = 1)
		INSERT INTO #ref (reference) VALUES ('490035-2100')												-- UE21
	IF(@3200 = 1)
		INSERT INTO #ref (reference) VALUES ('490035-3200')												-- UE24
	IF(@3300 = 1)
		INSERT INTO #ref (reference) VALUES ('490035-3300')												-- UE24



	DECLARE curseur_of CURSOR STATIC																	-- Création d'un curseur pour l'obtention de plusieurs valeurs de RunId
	FOR SELECT currentOF, reference 
		FROM [dbo].[QAGATE_1_MainTable]
		WHERE reference IN (SELECT reference FROM #ref)
		GROUP BY currentOF, reference

	OPEN curseur_of																						-- Ouverture du curseur
	SET @NbrRows = @@CURSOR_ROWS																		-- Compte le nombre de lignes (rows)

	WHILE(@NbrRows > 0)																					-- Boucle % au curseur runid pour faire du tri sur le catalogue de données

		BEGIN
			FETCH NEXT FROM curseur_of INTO @OF, @Reference												-- Copie la ligne de la première ligne dans @RunID
			
			SELECT TOP(1) @DateDebut = timeStamp FROM QAGATE_1_MainTable WHERE currentOF = @OF ORDER BY timeStamp ASC
			SELECT TOP(1) @DateFin = timeStamp FROM QAGATE_1_MainTable WHERE currentOF = @OF ORDER BY timeStamp DESC

			INSERT INTO #temp_table (currentOF, reference, date_Debut, date_Fin) VALUES (@OF, @Reference, @DateDebut, @DateFin)

			SET @NbrRows -= 1																			-- Décrémentation
			CONTINUE																					-- Retour au FETCH
		END

	CLOSE curseur_of																					-- Fermeture du curseur
	DEALLOCATE curseur_of																				-- Suppression du curseur

	SELECT currentOF, reference, FORMAT (date_Debut, 'dd/MM/yy HH:mm:ss') AS 'dateDebut', FORMAT (date_Fin, 'dd/MM/yy HH:mm:ss') AS 'dateFin' 
	FROM #temp_table
	WHERE date_Debut >= @Debut AND date_Fin <= DATEADD(DAY, 1, CAST(@Fin AS DATETIME))
	ORDER BY date_Debut DESC
	

	DROP TABLE #temp_table

END