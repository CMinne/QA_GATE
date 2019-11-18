CREATE TABLE [dbo].[QAGATE_1_NombrePiece] (
    [idNombre] INT IDENTITY (1, 1) NOT NULL,
    [nombre]        INT NOT NULL,
    [idClient]       INT NOT NULL,
    PRIMARY KEY CLUSTERED ([idNombre] ASC),
    CONSTRAINT [FK_Nombre_Piece_Reference] FOREIGN KEY ([idClient]) REFERENCES [dbo].[QAGATE_1_Client] ([idClient])
);

