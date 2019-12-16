-- =============================================
-- Author: <Minne Charly>
-- Create date: <10/12/2019>
-- Update: <10/12/2019>
-- Description:	< Ce programme permet de récupérer les évènements venant de la QA Gate. >
-- =============================================

-- VALIDER --

CREATE PROCEDURE [dbo].[QAGATE_1_ExtractionQGEvent](
	@OF VARCHAR(10)
)
AS

	SET NOCOUNT ON																					-- Obligatoire

BEGIN
	SELECT idEvent, reference, currentOF, mnemoniqueAlarme, etat, timeStamp 
	FROM [dbo].[QAGATE_1_EventData] 
	INNER JOIN [dbo].[QAGATE_1_EventInfo] 
	ON [dbo].[QAGATE_1_EventData].[code] = [dbo].[QAGATE_1_EventInfo].[code] 
	WHERE currentOF = @OF
	ORDER BY idEvent
END