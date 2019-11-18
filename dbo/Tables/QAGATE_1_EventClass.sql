CREATE TABLE [dbo].[QAGATE_1_EventClass] (
    [Id_Event_Class] INT          IDENTITY (1, 1) NOT NULL,
    [Class]          SMALLINT     NOT NULL,
    [Nom]            VARCHAR (20) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id_Event_Class] ASC),
    UNIQUE NONCLUSTERED ([Class] ASC)
);

