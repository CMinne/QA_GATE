CREATE TABLE [dbo].[QAGATE_1_MainTable] (
    [Id_Piece]     INT          IDENTITY (1, 1) NOT NULL,
    [Reference]    VARCHAR (15) NOT NULL,
    [Current_OF]   VARCHAR (10) NOT NULL,
    [OK]           BIT          DEFAULT ((1)) NOT NULL,
    [Keyence_Etat] BIT          DEFAULT ((0)) NOT NULL,
    [Kogame_Etat]  BIT          DEFAULT ((0)) NOT NULL,
    [Heure_Reseau] DATETIME     DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id_Piece] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ind_Current_OF]
    ON [dbo].[QAGATE_1_MainTable]([Current_OF] ASC);

