CREATE TABLE [dbo].[QAGATE_1_EventInfo] (
    [idInfo]    INT           IDENTITY (1, 1) NOT NULL,
    [code]             SMALLINT      NOT NULL,
    [class]            SMALLINT      NOT NULL,
    [mnemoniqueAlarme] VARCHAR (MAX) NULL,
    [description]      VARCHAR (MAX) NULL,
    [cause]            VARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([idInfo] ASC),
    CONSTRAINT [FK_Event_Info_Event_Class] FOREIGN KEY ([class]) REFERENCES [dbo].[QAGATE_1_EventClass] ([class]),
    UNIQUE NONCLUSTERED ([code] ASC)
);

