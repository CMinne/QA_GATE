CREATE TABLE [dbo].[QAGATE_1_MainTable] (
    [idPiece]     INT          IDENTITY (1, 1) NOT NULL,
    [reference]    VARCHAR (15) NOT NULL,
    [currentOF]   VARCHAR (10) NOT NULL,
    [OK]           BIT          DEFAULT ((1)) NOT NULL,
    [keyenceEtat] BIT          DEFAULT ((0)) NOT NULL,
    [kogameEtat]  BIT          DEFAULT ((0)) NOT NULL,
    [timeStamp] DATETIME     DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([idPiece] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ind_Current_OF]
    ON [dbo].[QAGATE_1_MainTable]([currentOF] ASC);

