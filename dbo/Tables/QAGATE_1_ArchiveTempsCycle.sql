CREATE TABLE [dbo].[QAGATE_1_ArchiveTempsCycle] (
    [Id_Archive] INT            IDENTITY (1, 1) NOT NULL,
    [Cycle]      DECIMAL (3, 1) NOT NULL,
    [Date]       DATETIME       DEFAULT (getdate()) NOT NULL,
    [Id_Client]  INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([Id_Archive] ASC),
    CONSTRAINT [FK_Archive_Temps_Cycle_Client] FOREIGN KEY ([Id_Client]) REFERENCES [dbo].[QAGATE_1_Client] ([Id_Client])
);

