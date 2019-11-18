CREATE TABLE [dbo].[Kogame_Data] (
    [Id_Kogame]           INT        IDENTITY (1, 1) NOT NULL,
    [Hauteur]             FLOAT (53) DEFAULT (NULL) NULL,
    [Parallelisme_Face]   FLOAT (53) DEFAULT (NULL) NULL,
    [Planeite_face_Hexag] FLOAT (53) DEFAULT (NULL) NULL,
    [Planeite]            FLOAT (53) DEFAULT (NULL) NULL,
    [Rectitude_Face_1]    FLOAT (53) DEFAULT (NULL) NULL,
    [Rectitude_Face_2]    FLOAT (53) DEFAULT (NULL) NULL,
    [Heure_Reseau]        DATETIME   DEFAULT (getdate()) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id_Kogame] ASC)
);

