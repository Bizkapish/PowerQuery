let
//This is for development and testing. Read the comment at the bottom. Real function is bellow.
    Tabelix = #table( type table [Country=text,City=text, Value=number], { { "France", "Paris", 10 }
                                                                              , { "France", "Paris", 20 }
                                                                              , { "France", "Marseille", 30 }
                                                                              , { "US", "Paris", 40 }
                                                                              , { "US", "LA", 50 }
                                                                              , { "US", "LA", 60 } })
    , Columns = { "Country", "City" }
    , NewColumnName = "EnumeratedCity"
//Body: We will take distinct rows from the columns "Continent" and Country. We will sort those rows ascending and we will create an index for them. Then we will join those values to original table.
        , ColumnsDistinct = Table.Group( Tabelix, Columns, { { "Unimportant", each null  } } )  //we must have aggregation for Table.Group to work, although we don't need it.
        , RemoveUnimportantColumn = Table.RemoveColumns( ColumnsDistinct, "Unimportant")
        , Sorting = Table.Sort( RemoveUnimportantColumn, List.Zip( {    List.Reverse( Columns ), List.Repeat( { Order.Ascending }, List.Count( Columns ) )    } )      )    //List.Reverse becuse we want to sort by the last column fist.   
//Now we join with original table.
        , addPrefixForJoin = Table.PrefixColumns( Sorting, "Prefix" )
        , addcIndex = Table.AddIndexColumn( addPrefixForJoin, NewColumnName, 1 ) //only now we add index.
        , ColumnsWithPrefix = List.Transform( Columns, each "Prefix." & _ )        
        , JoinWithOriginalTable = Table.Join( Tabelix, Columns, addcIndex, ColumnsWithPrefix, JoinKind.Inner )
//We delete duplicate columns used in join. 
        , RemoveDuplicateColumns = Table.RemoveColumns( JoinWithOriginalTable, ColumnsWithPrefix )

    //lets make a function from this body. This function has the same body as above.
    , fnEnumerateColumn = ( Tabelix as table, Columns as text, NewColumnName as text ) as table =>
      let 
        //Body: We will take distinct rows from the columns "Continent" and Country. We will sort those rows ascending and we will create an index for them. Then we will join those values to original table.
        ColumnsDistinct = Table.Group( Tabelix, Columns, { { "Unimportant", each null  } } )  //we must have aggregation for Table.Group to work, although we don't need it.
        , RemoveUnimportantColumn = Table.RemoveColumns( ColumnsDistinct, "Unimportant")
        , Sorting = Table.Sort( RemoveUnimportantColumn, List.Zip( {    List.Reverse( Columns ), List.Repeat( { Order.Ascending }, List.Count( Columns ) )    } )      )       
        //Now we join with original table.
        , addPrefixForJoin = Table.PrefixColumns( Sorting, "Prefix" )
        , addcIndex = Table.AddIndexColumn( addPrefixForJoin, NewColumnName, 1 ) //only now we add index.
        , ColumnsWithPrefix = List.Transform( Columns, each "Prefix." & _ )        
        , JoinWithOriginalTable = Table.Join( Tabelix, Columns, addcIndex, ColumnsWithPrefix, JoinKind.Inner )
        //We delete duplicate columns used in join. 
        , RemoveDuplicateColumns = Table.RemoveColumns( JoinWithOriginalTable, ColumnsWithPrefix )
      in
        RemoveDuplicateColumns

//Now we will create documentation for our function.    
    , fnDocumentation = type function ( Tabelix as table, Columns as text, NewColumnName as text ) as list meta  
        [ Documentation.Name = "fnEnumerateColumn"
          , Documentation.LongDescription = "Second argument should be list of columns where column with the smallest granularity should be the last. For those columns we would take distinct rows from the table. Those distinct rows will be sorted in ascending
                                             order, first by column with the smallest granularity, and then by columns with bigger granularity (we use reverse order). Then, we would add index column to such distinct rows.
                                             Now we have indexes that can be added to original table to enumerate each unique row. 

                                             This basically enumerate only the column with the smallest granularity, but we have to take in account existance of duplicates. In the column with the smallest granularity we could have city Paris, but one Paris could be
                                             in France and the other one in US. If we don't want to make distinction between them then second argument should be { ""City"" }, but if we want to, then second argument should be { ""Country"", ""City"" }.
                                             In the first case ""Paris"" will be enumerated with one number, but in second case ""Paris"" will be enumerated with two numbers."
                                              
          , Documentation.Examples = { [ Description = "We have a table with three columns and sixt rows. First two columns are 'Country' and 'City'. We want to add another column which will label all of the cities with numbers. Last argument is the name of that column                                              ( EnumeratedCity ). For the second argument we could take list { ""Country"", ""City"" }. This would label city Paris with numbers 2 and 3 becuse there is Paris in France and Paris in US. 
                                                        If we use { ""City"" } as second argument then Paris would be labeled only with number 2.
                                                        First argument is the table we are working on."
                                       , Code = "fnEnumerateColumn( #table( type table [Country=text,City=text, Value=number], { { ""France"", ""Paris"", 10 }
                                                                              , { ""France"", ""Paris"", 20 }
                                                                              , { ""France"", ""Marseille"", 30 }
                                                                              , { ""US"", ""Paris"", 40 }
                                                                              , { ""US"", ""LA"", 50 }
                                                                              , { ""US"", ""LA"", 60 } })
                                                                              , { ""Country"", ""City"" }
                                                                              , ""EnumeratedCity""  )"
                                       , Result = "#table( type table [Country=text,City=text,EnumeratedCity=number,Value=number], { { ""France"", ""Paris"", 10, 3 }
                                                                              , { ""France"", ""Paris"", 20, 3 }
                                                                              , { ""France"", ""Marseille"", 30, 1 }
                                                                              , { ""US"", ""Paris"", 40, 2 }
                                                                              , { ""US"", ""LA"", 50, 4 }
                                                                              , { ""US"", ""LA"", 60, 1 } } )"   ]  } ]
    , AddDocumentationToFunction = Value.ReplaceType( fnEnumerateColumn, fnDocumentation )
    , Result = if false then RemoveDuplicateColumns else AddDocumentationToFunction     //by toggling true/false you can return function or procedure. Procedure is used for function development, because then you can see the steps in PQ GUI.
                                                                   //After you modify procedure, you place body of procedure inside of function. That is the easiest way of development.   
                                                               
in 
    Result
