CREATE TABLE [dbo].[QAGATE_1_Reference] (
    [idReference] INT          IDENTITY (1, 1) NOT NULL,
    [nameReference]        VARCHAR (15) NOT NULL,
    [idClient]    INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([idReference] ASC),
    CONSTRAINT [FK_Reference_Client] FOREIGN KEY ([idClient]) REFERENCES [dbo].[QAGATE_1_Client] ([idClient])
);

