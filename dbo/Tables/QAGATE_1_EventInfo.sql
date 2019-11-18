CREATE TABLE [dbo].[QAGATE_1_EventInfo] (
    [Id_Event_Info]    INT           IDENTITY (1, 1) NOT NULL,
    [Code]             SMALLINT      NOT NULL,
    [Class]            SMALLINT      NOT NULL,
    [MnemoniqueAlarme] VARCHAR (MAX) NULL,
    [Description]      VARCHAR (MAX) NULL,
    [Cause]            VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([Id_Event_Info] ASC),
    CONSTRAINT [FK_Event_Info_Event_Class] FOREIGN KEY ([Class]) REFERENCES [dbo].[QAGATE_1_EventClass] ([Class]),
    UNIQUE NONCLUSTERED ([Code] ASC)
);

