CREATE TABLE [dbo].[QAGATE_1_NombrePiece] (
    [Id_Nombre_Piece] INT IDENTITY (1, 1) NOT NULL,
    [Quantite]        INT NOT NULL,
    [Id_Client]       INT NOT NULL,
    PRIMARY KEY CLUSTERED ([Id_Nombre_Piece] ASC),
    CONSTRAINT [FK_Nombre_Piece_Reference] FOREIGN KEY ([Id_Client]) REFERENCES [dbo].[QAGATE_1_Client] ([Id_Client])
);

