CREATE TABLE [dbo].[QAGATE_1_Cycle] (
    [idCycle]    INT            IDENTITY (1, 1) NOT NULL,
    [tempsCycle] DECIMAL (5, 1) NOT NULL,
    [idClient]   INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([idCycle] ASC),
    CONSTRAINT [FK_Cycle_Client] FOREIGN KEY ([idClient]) REFERENCES [dbo].[QAGATE_1_Client] ([idClient])
);

