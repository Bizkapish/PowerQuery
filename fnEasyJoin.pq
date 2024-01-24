let
//This is for development and testing. Read the comment at the bottom. Real function is bellow.
    T1 = #table( type table [A=text,B=text, C=text, Fact1=number], { { "A1", "B1", "C1", 50 }, { "A2", "B2", "C2", 200 } } )      //these are sample data
    , T2 = #table( type table [A=text,B=text, C=text, Fact2=number], { { "A1", "B1", "C1", 3 }, { "A2", "B2", "C2", 700 } } )          
    , T1joinColumns = { "A", "B" } 
    , T2joinColumns = { "A", "B" }
    , JoinKind = JoinKind.Inner
//Body: We will join T1 and T2 tables. All columns from T2 that are duplicates by the name, or are part of a join columns, will be deleted.
    , T1columnsNames = Table.ColumnNames( T1 )  //we get column names
    , T2columnsNames = Table.ColumnNames( T2 )
    , T1T2duplicates = List.Intersect( { T1columnsNames, T2columnsNames } )   //we find duplicates
    , T2duplicateColumnsPrefix = Table.TransformColumnNames( T2, each if List.Contains( T1T2duplicates, _ ) then "T2." & _ else _ )    //we prefix duplicates in T2
    , T2joinColumnsPrefix = List.Transform( T2joinColumns, each if List.Contains( T1T2duplicates, _ ) then "T2." & _ else _ )    //we prefix duplicates in T2joinColumns
    , T1T2join = Table.Join( T1, T1joinColumns, T2duplicateColumnsPrefix, T2joinColumnsPrefix, JoinKind )         //we make a join
    , PrefixedInT2 = List.Select( Table.ColumnNames( T2duplicateColumnsPrefix ), each Text.Start( _, 3 ) = "T2." )   //we find all the columns from the T2 that are prefixed with T2 and we remove them in the next step
    , RemoveT2joinOrDuplicateColumns = Table.RemoveColumns( T1T2join, List.Distinct( T2joinColumnsPrefix & PrefixedInT2 ) )

    //lets make a function from this body. This function has the same body as above.
    , fnEasyJoin = ( T1 as table, T1joinColumns as list, T2 as table, T2joinColumns as list, JoinKind as number  ) as table  => 
      let 
        T1columnsNames = Table.ColumnNames( T1 )  //we get column names
        , T2columnsNames = Table.ColumnNames( T2 )
        , T1T2duplicates = List.Intersect( { T1columnsNames, T2columnsNames } )   //we find duplicates
        , T2duplicateColumnsPrefix = Table.TransformColumnNames( T2, each if List.Contains( T1T2duplicates, _ ) then "T2." & _ else _ )    //we prefix duplicates in T2
        , T2joinColumnsPrefix = List.Transform( T2joinColumns, each if List.Contains( T1T2duplicates, _ ) then "T2." & _ else _ )    //we prefix duplicates in T2joinColumns
        , T1T2join = Table.Join( T1, T1joinColumns, T2duplicateColumnsPrefix, T2joinColumnsPrefix, JoinKind )         //we make a join
        , PrefixedInT2 = List.Select( Table.ColumnNames( T2duplicateColumnsPrefix ), each Text.Start( _, 3 ) = "T2." )   //we find all the columns from the T2 that are prefixed with T2 and we remove them in the next step
        , RemoveT2joinOrDuplicateColumns = Table.RemoveColumns( T1T2join, List.Distinct( T2joinColumnsPrefix & PrefixedInT2 ) )
      in
        RemoveT2joinOrDuplicateColumns

//Now we will create documentation for our function.    
    , fnDocumentatation = type function ( T1 as table, T1joinColumns as list, T2 as table, T2joinColumns as list, JoinKind as number ) as list meta  
        [ Documentation.Name = "fnEasyJoin"
          , Documentation.LongDescription = "This function will join two tables directly. There will be no problem with duplicate column names. All duplicate columns from Table 2 will be prefixed. After join, all duplicate
                                             columns from the Table 2, and all the columns from the Table 2 that are used for join, will be deleted."
          , Documentation.Examples = { [ Description = "We have two tables, T1 and T2. First table has columns { ""A"", ""B"", ""C"", ""Fact1"" }. Second table has the same columns, just the name of the last column is ""Fact2"".
                                                        We will join these two columns based on join columns ""A"" and ""B"". After that we will delete column ""C"" from the table T2, because it is a duplicate by its name.
                                                        We will also delete columns ""A"" and ""B"" from the table T2, because they are used for the join, so they are duplicates."
                                       , Code = "fnEasyJoin( #table( type table [A=text,B=text, C=text, Fact1=number], { { ""A1"", ""B1"", ""C1"", 50 }, { ""A2"", ""B2"", ""C2"", 200 } } ) 
                                                , { ""A"", ""B"" } 
                                                , #table( type table [A=text,B=text, C=text, Fact2=number], { { ""A1"", ""B1"", ""C1"", 3 }, { ""A2"", ""B2"", ""C2"", 700 } } )          
                                                , { ""A"", ""B"" }
                                                , JoinKind.Inner )"                                          
                                       , Result = "#table( type table [A=text,B=text,C=text,Fact1=number,Fact2=number]
                                                , { { ""A1"", ""B1"", ""C1"", 50, 3 }
                                                    , { ""A2"", ""B2"", ""C2"", 200, 700 } } )"     ]  } ]
    , AddDocumentationToFunction = Value.ReplaceType( fnEasyJoin, fnDocumentatation )
    , Result = if true then AddDocumentationToFunction else RemoveT2joinOrDuplicateColumns     //by toggling true/false you can return function or procedure. Procedure is used for function development, because then you can see the steps in PQ GUI.
                                                                   //After you modify procedure, you place body of procedure inside of function. That is the easiest way of development.   
                
in
    Result