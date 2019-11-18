CREATE TABLE [dbo].[QAGATE_1_EtatSysteme] (
    [Id]        INT          IDENTITY (1, 1) NOT NULL,
    [Etat]      SMALLINT     NOT NULL,
    [Name_Etat] VARCHAR (10) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    UNIQUE NONCLUSTERED ([Etat] ASC)
);

