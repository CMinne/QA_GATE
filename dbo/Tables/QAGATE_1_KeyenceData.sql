CREATE TABLE [dbo].[QAGATE_1_KeyenceData] (
    [idKeyence]      INT          IDENTITY (1, 1) NOT NULL,
    [reference]      VARCHAR (15) NOT NULL,
    [currentOF]       VARCHAR (10) NOT NULL,
    [doubleTaillage] BIT          DEFAULT (NULL) NULL,
    [coupDenture1]  BIT          DEFAULT (NULL) NULL,
    [coupDenture2]  BIT          DEFAULT (NULL) NULL,
    [chanfrein1]     BIT          DEFAULT (NULL) NULL,
    [chanfrein2]     BIT          DEFAULT (NULL) NULL,
    [chanfrein3]     BIT          DEFAULT (NULL) NULL,
    [chanfrein4]     BIT          DEFAULT (NULL) NULL,
    [timeStamp]    DATETIME     DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([idKeyence] ASC)
);