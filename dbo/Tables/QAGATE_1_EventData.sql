CREATE TABLE [dbo].[QAGATE_1_EventData] (
    [idEvent]    INT          IDENTITY (1, 1) NOT NULL,
    [reference]   VARCHAR (15) NOT NULL,
    [currentOF]  VARCHAR (10) NOT NULL,
    [code]        SMALLINT     NOT NULL,
    [etat]        SMALLINT     NOT NULL,
    [timeStamp] DATETIME     DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([idEvent] ASC),
    CONSTRAINT [FK_QAGATE_1_EventData_QAGATE_1_EtatSysteme] FOREIGN KEY ([etat]) REFERENCES [dbo].[QAGATE_1_EtatSysteme] ([etat]),
    CONSTRAINT [FK_QAGATE_1_EventData_QAGATE_1_EventInfo] FOREIGN KEY ([code]) REFERENCES [dbo].[QAGATE_1_EventInfo] ([code])
);

