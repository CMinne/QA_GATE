CREATE TABLE [dbo].[QAGATE_1_EtatSysteme] (
    [idEtat]        INT          IDENTITY (1, 1) NOT NULL,
    [etat]      SMALLINT     NOT NULL,
    [nameEtat] VARCHAR (10) NOT NULL,
    PRIMARY KEY CLUSTERED ([idEtat] ASC),
    UNIQUE NONCLUSTERED ([etat] ASC)
);

