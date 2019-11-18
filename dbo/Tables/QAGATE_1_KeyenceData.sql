CREATE TABLE [dbo].[QAGATE_1_KeyenceData] (
    [Id_Keyence]      INT          IDENTITY (1, 1) NOT NULL,
    [Current_OF]      VARCHAR (10) NOT NULL,
    [Reference]       VARCHAR (15) NOT NULL,
    [Double_Taillage] BIT          DEFAULT (NULL) NULL,
    [Coup_Denture_1]  BIT          DEFAULT (NULL) NULL,
    [Coup_Denture_2]  BIT          DEFAULT (NULL) NULL,
    [Chanfrein_1]     BIT          DEFAULT (NULL) NULL,
    [Chanfrein_2]     BIT          DEFAULT (NULL) NULL,
    [Chanfrein_3]     BIT          DEFAULT (NULL) NULL,
    [Chanfrein_4]     BIT          DEFAULT (NULL) NULL,
    [Heure_Reseau]    DATETIME     DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id_Keyence] ASC)
);