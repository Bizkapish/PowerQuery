let
//This is for development and testing. Read the comment at the bottom. Real function is bellow.
    Tabelix = #table( type table [Continent=text,Country=text], { { "Africa", "Marocco" }
                                                      , { "Africa", "Tanzania" }
                                                      , { "Asia", "China" }
                                                      , { "Asia", "Vietnam" } })
    , Column = "Continent"
    , NewColumnName = "ContinentEnumerated"
//Body: We will take distinct values from the column "kontinent". We will sort those values ascending and we will create an index for them. Then we will join those values to original table.
        , ColumnDistinct = Table.Distinct( Table.SelectColumns( Tabelix, { Column } ) )
        , Sorting = Table.Sort( ColumnDistinct, { Column, Order.Ascending } )
        , addcIndex = Table.AddIndexColumn( Sorting, NewColumnName, 1 )
//Now we join with original table.
        , ColumnWithPrefix = "Prefix." & Column
        , AddPrefix = Table.RenameColumns( addcIndex, { Column, ColumnWithPrefix } )
        , JoinWithOriginalTable = Table.Join( Tabelix, { Column }, AddPrefix, { ColumnWithPrefix }, JoinKind.Inner )
//We delete column ColumnWithPrefix because we don't need it
        , DeleteColumnWithPrefix = Table.RemoveColumns( JoinWithOriginalTable, { ColumnWithPrefix } )        
        

    //lets make a function from this body. This function has the same body as above.
    , fnEnumerateColumn = ( Tabelix as table, Column as text, NewColumnName as text ) as table =>
      let 
        //Body: We will take distinct values from the column "kontinent". We will sort those values ascending and we will create an index for them. Then we will join those values to original table.
        ColumnDistinct = Table.Distinct( Table.SelectColumns( Tabelix, { Column } ) )
        , Sorting = Table.Sort( ColumnDistinct, { Column, Order.Ascending } )
        , addcIndex = Table.AddIndexColumn( Sorting, NewColumnName, 1 )
        //Now we join with original table.
        , ColumnWithPrefix = "Prefix." & Column
        , AddPrefix = Table.RenameColumns( addcIndex, { Column, ColumnWithPrefix } )
        , JoinWithOriginalTable = Table.Join( Tabelix, { Column }, AddPrefix, { ColumnWithPrefix }, JoinKind.Inner )
        //We delete column ColumnWithPrefix because we don't need it
        , DeleteColumnWithPrefix = Table.RemoveColumns( JoinWithOriginalTable, { ColumnWithPrefix } )  
      in
        DeleteColumnWithPrefix

//Now we will create documentation for our function.    
    , fnDocumentation = type function ( Tabelix as table, Column as text, NewColumnName as text ) as list meta  
        [ Documentation.Name = "fnEnumerateColumn"
          , Documentation.LongDescription = "This function will create new column based on some existing column. All distinct values from existing column will be sorted ASC, and then they will be labeled with values 1,2,3,4.....
                                             Those numbers will make values for a new column. In that way, new column will be enumeration of a existing column."
          , Documentation.Examples = { [ Description = "We have a table with two columns and four rows. Two columns are 'Continent' and 'Country'. We want to add another columns which will labeled all of the continents from the column
                                                        Continent with numbers. That is how our continents will be enumerated. In column 'Continent' we have continents 'Africa' and 'Asia'. In new column 'ContinentEnumerated', for 'Africa' we will have 1,
                                                        and for 'Asia' we will have 2."
                                       , Code = "fnEnumerateColumn( #table( type table [Continent=text,Country=text], { { ""Africa"", ""Marocco"" }
                                                                                                                      , { ""Africa"", ""Tanzania"" }
                                                                                                                      , { ""Asia"", ""China"" }
                                                                                                                      , { ""Asia"", ""Vietnam"" } } )
                                                                  , ""Continent""
                                                                  , ""EnumeratedContinent""  )"
                                       , Result = "#table( type table [Continent=text,Country=text,ContinentEnumerated=number], { { ""Africa"", ""Marocco"", 1 }
                                                                                                                                , { ""Africa"", ""Tanzania"", 1 }
                                                                                                                                , { ""Asia"", ""China"", 2 }
                                                                                                                                , { ""Asia"", ""Vietnam"", 2 } } )"  ]  } ]
    , AddDocumentationToFunction = Value.ReplaceType( fnEnumerateColumn, fnDocumentation )
    , Result = if false then DeleteColumnWithPrefix else AddDocumentationToFunction     //by toggling true/false you can return function or procedure. Procedure is used for function development, because then you can see the steps in PQ GUI.
                                                                   //After you modify procedure, you place body of procedure inside of function. That is the easiest way of development.   
in 
    Result