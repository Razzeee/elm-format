{-# OPTIONS_GHC -Wall -fno-warn-unused-do-bind #-}
module Parse.Declaration where

import Text.Parsec ( (<|>), (<?>), choice, digit, optionMaybe, string, try )

import AST.Declaration
import Parse.Comments
import qualified Parse.Expression as Expr
import Parse.Helpers as Help
import qualified Parse.Type as Type
import AST.V0_16
import Parse.IParser
import Parse.Whitespace


declaration :: IParser Declaration
declaration =
    typeDecl <|> infixDecl <|> port <|> definition


topLevelStructure :: IParser a -> IParser (TopLevelStructure a)
topLevelStructure entry =
    choice
        [ DocComment <$> docCommentAsMarkdown
        , Entry <$> addLocation entry
        ]



-- TYPE ANNOTATIONS and DEFINITIONS

definition :: IParser AST.Declaration.Declaration
definition =
    (Expr.typeAnnotation TypeAnnotation <|> Expr.definition Definition)
    <?> "a value definition"


-- TYPE ALIAS and UNION TYPES

typeDecl :: IParser AST.Declaration.Declaration
typeDecl =
  do  try (reserved "type") <?> "a type declaration"
      postType <- forcedWS
      isAlias <- optionMaybe (string "alias" >> forcedWS)

      name <- capVar
      args <- spacePrefix lowVar
      (preEquals, _, postEquals) <- padded equals

      case isAlias of
        Just postAlias ->
            do  tipe <- Type.expr <?> "a type"
                return $
                  AST.Declaration.TypeAlias
                    postType
                    (Commented postAlias (name, args) preEquals)
                    (postEquals, tipe)

        Nothing ->
            do
                tags_ <- pipeSep1 Type.tag <?> "a constructor for a union type"
                return
                    AST.Declaration.Datatype
                        { nameWithArgs = Commented postType (name, args) preEquals
                        , tags = exposedToOpen postEquals tags_
                        }


-- INFIX


infixDecl :: IParser AST.Declaration.Declaration
infixDecl =
    expecting "an infix declaration" $
    choice
        [ try infixDecl_0_16
        , infixDecl_0_19
        ]


infixDecl_0_19 :: IParser AST.Declaration.Declaration
infixDecl_0_19 =
    let
        assoc =
            choice
                [ string "right" >> return AST.Declaration.R
                , string "non" >> return AST.Declaration.N
                , string "left" >> return AST.Declaration.L
                ]
    in
    AST.Declaration.Fixity_0_19
        <$> (try (reserved "infix") *> preCommented assoc)
        <*> (preCommented $ (\n -> read [n]) <$> digit)
        <*> (commented symOpInParens)
        <*> (equals *> preCommented lowVar)


infixDecl_0_16 :: IParser AST.Declaration.Declaration
infixDecl_0_16 =
  do  assoc <-
          choice
            [ try (reserved "infixl") >> return AST.Declaration.L
            , try (reserved "infixr") >> return AST.Declaration.R
            , try (reserved "infix")  >> return AST.Declaration.N
            ]
      digitComments <- forcedWS
      n <- digit
      opComments <- forcedWS
      AST.Declaration.Fixity assoc digitComments (read [n]) opComments <$> anyOp


-- PORT

port :: IParser AST.Declaration.Declaration
port =
  expecting "a port declaration" $
  do  try (reserved "port")
      preNameComments <- whitespace
      name <- lowVar
      postNameComments <- whitespace
      let name' = Commented preNameComments name postNameComments
      choice [ portAnnotation name', portDefinition name' ]
  where
    portAnnotation name =
      do  try hasType
          typeComments <- whitespace
          tipe <- Type.expr <?> "a type"
          return (AST.Declaration.PortAnnotation name typeComments tipe)

    portDefinition name =
      do  try equals
          bodyComments <- whitespace
          expr <- Expr.expr
          return (AST.Declaration.PortDefinition name bodyComments expr)
