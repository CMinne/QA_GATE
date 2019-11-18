CREATE TABLE [dbo].[QAGATE_1_EventData] (
    [Id_Event]    INT          IDENTITY (1, 1) NOT NULL,
    [Reference]   VARCHAR (15) NOT NULL,
    [Current_OF]  VARCHAR (10) NOT NULL,
    [Code]        SMALLINT     NOT NULL,
    [Etat]        SMALLINT     NOT NULL,
    [Heure_Event] DATETIME     DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id_Event] ASC),
    CONSTRAINT [FK_QAGATE_1_EventData_QAGATE_1_EtatSysteme] FOREIGN KEY ([Etat]) REFERENCES [dbo].[QAGATE_1_EtatSysteme] ([Etat]),
    CONSTRAINT [FK_QAGATE_1_EventData_QAGATE_1_EventInfo] FOREIGN KEY ([Code]) REFERENCES [dbo].[QAGATE_1_EventInfo] ([Code])
);

