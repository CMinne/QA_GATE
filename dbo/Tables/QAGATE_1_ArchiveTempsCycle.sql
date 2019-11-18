CREATE TABLE [dbo].[QAGATE_1_ArchiveTempsCycle] (
    [idArchive] INT            IDENTITY (1, 1) NOT NULL,
    [cycle]      DECIMAL (3, 1) NOT NULL,
    [timeStamp]       DATETIME       DEFAULT (getdate()) NOT NULL,
    [idClient]  INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([idArchive] ASC),
    CONSTRAINT [FK_Archive_Temps_Cycle_Client] FOREIGN KEY ([idClient]) REFERENCES [dbo].[QAGATE_1_Client] ([idClient])
);

