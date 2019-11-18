CREATE TABLE [dbo].[QAGATE_1_Client] (
    [Id_Client]   INT          IDENTITY (1, 1) NOT NULL,
    [Names]       VARCHAR (10) NOT NULL,
    [Commentaire] TEXT         NULL,
    PRIMARY KEY CLUSTERED ([Id_Client] ASC)
);

