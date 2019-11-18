CREATE TABLE [dbo].[QAGATE_1_Cycle] (
    [Id_Cycle]    INT            IDENTITY (1, 1) NOT NULL,
    [Temps_Cycle] DECIMAL (3, 1) NOT NULL,
    [Id_Client]   INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([Id_Cycle] ASC),
    CONSTRAINT [FK_Cycle_Client] FOREIGN KEY ([Id_Client]) REFERENCES [dbo].[QAGATE_1_Client] ([Id_Client])
);

