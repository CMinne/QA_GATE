CREATE TABLE [dbo].[QAGATE_1_EventClass] (
    [idClass] INT          IDENTITY (1, 1) NOT NULL,
    [class]          SMALLINT     NOT NULL,
    [nameClass]            VARCHAR (20) NOT NULL,
    PRIMARY KEY CLUSTERED ([idClass] ASC),
    UNIQUE NONCLUSTERED ([class] ASC)
);

