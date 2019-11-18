CREATE TABLE [dbo].[QAGATE_1_Reference] (
    [Id_Reference] INT          IDENTITY (1, 1) NOT NULL,
    [Names]        VARCHAR (15) NOT NULL,
    [Id_Client]    INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([Id_Reference] ASC),
    CONSTRAINT [FK_Reference_Client] FOREIGN KEY ([Id_Client]) REFERENCES [dbo].[QAGATE_1_Client] ([Id_Client])
);

