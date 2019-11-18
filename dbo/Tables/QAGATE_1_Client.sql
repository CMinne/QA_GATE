CREATE TABLE [dbo].[QAGATE_1_Client] (
    [idClient]   INT          IDENTITY (1, 1) NOT NULL,
    [nameClient]       VARCHAR (10) NOT NULL,
    [commentaire] TEXT         NULL,
    PRIMARY KEY CLUSTERED ([idClient] ASC)
);

