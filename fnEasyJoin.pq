let
// * duplicate columns are columns with the same name in tables T1 and T2    ( A, B, C )
// * join columns are columns used for join   ( A, B )
// * other columns are columns that are not used for join.   ( C, Fact )
// * other non duplicate columns - those are other columns that are not duplicates by name   ( Fact )
// * other duplicate columns - those are other columns that are duplicates by name   ( C )

//This is for development and testing. Read the comment at the bottom. Real function is bellow.
    T1 = #table( type table [A=text,B=text, C=text, Fact1=number], { { "A1", "B1", "C1", 50 }, { "A2", "B2", "C2", 200 } } )      //these are sample data
    , T2 = #table( type table [A=text,B=text, C=text, Fact2=number], { { "A1", "B1", "C1", 3 }, { "A2", "B2", "C2", 700 } } )          
    , T1joinColumns = { "A", "B" } 
    , T2joinColumns = { "A", "B" }
    , JoinKind = JoinKind.FullOuter
    , PreserveT2joinColumns = false
    , PreserveT2duplicateOtherColumns = false
    , PreservePrefixT2forNonDuplicateOtherColumns = false
//Body: We will join T1 and T2 tables. All columns from T2 that are join columns, or if they are duplicates by name, will be deleted, except if user don't use arguments Preserve... Then they will have prefix T2.
//All other non duplicate columns from T2 will not have prefix T2, except if user don't use argument PreservePrefixT2.
        , T1columnNames = Table.ColumnNames( T1 )  //we get column names
        , T2columnNames = Table.ColumnNames( T2 )
        , prefixT2joinColumns = List.Transform( T2joinColumns, each "T2." & _ )  //T2 prefix for T2 join columns  ( T2.A and T2.B ).
        , otherT2Columns = List.Difference( T2columnNames, T2joinColumns )             //T2 columns that are not used for join    ( C and Fact2 ).
        , duplicateT2otherColumns = List.Intersect( { T1columnNames, otherT2Columns } )            //T2 columns that are not used for join, but have the same name as some T1 columns  ( C ).
        , prefixDuplicateT2otherColumns = List.Transform( duplicateT2otherColumns, each "T2." & _ )         //above columns, but with T2 prefix ( T2.C ).    
        , nonDuplicateOtherColumns = List.Difference( otherT2Columns, duplicateT2otherColumns )  //non duplicate other columns ( Fact2 )
        , prefixNonDuplicateOthercolumns = List.Transform( nonDuplicateOtherColumns, each "T2." & _ )  // above with T2 prefix ( T2.Fact2 )
        //we now do the join
        , prefixT2table = Table.PrefixColumns( T2, "T2")
        , T1T2join = Table.Join( T1, T1joinColumns, prefixT2table, prefixT2joinColumns, JoinKind )         //we make a join
        //now we fix optional arguments    
        , PreserveT2joinColumnsOptional = if PreserveT2joinColumns = null then false else PreserveT2joinColumns   //because this is optional argument
        , PreserveT2duplicateOtherColumnsOptional = if PreserveT2duplicateOtherColumns = null then false else PreserveT2duplicateOtherColumns //because this is optional argument
        , PreservePrefixT2forNonDuplicateOtherColumnsOptional = if PreservePrefixT2forNonDuplicateOtherColumns = null then false else PreservePrefixT2forNonDuplicateOtherColumns // it is optional argument
        //now we delete columns, except if user doesn't want to. And we also remove T2 prefix from non duplicate other columns.
        , DeleteT2joinColumns = if PreserveT2joinColumnsOptional = true then T1T2join else Table.RemoveColumns( T1T2join, prefixT2joinColumns )
        , DeleteT2duplicateOtherColumns = if PreserveT2duplicateOtherColumnsOptional = true then DeleteT2joinColumns else Table.RemoveColumns( DeleteT2joinColumns, prefixDuplicateT2otherColumns )        
        , T2nonDuplicateOtherColumnsWithoutPrefix = if PreservePrefixT2forNonDuplicateOtherColumns = true then DeleteT2duplicateOtherColumns else Table.RenameColumns( DeleteT2duplicateOtherColumns, List.Zip( { prefixNonDuplicateOthercolumns, nonDuplicateOtherColumns }) )

    //lets make a function from this body. This function has the same body as above.
    , fnEasyJoin = ( T1 as table, T1joinColumns as list, T2 as table, T2joinColumns as list, JoinKind as number, optional PreserveT2joinColumns as logical
                                , optional PreserveT2duplicateOtherColumns as logical, optional PreservePrefixT2forNonDuplicateOtherColumns as logical   ) as table  => 
      let 
        T1columnNames = Table.ColumnNames( T1 )  //we get column names
        , T2columnNames = Table.ColumnNames( T2 )
        , prefixT2joinColumns = List.Transform( T2joinColumns, each "T2." & _ )  //T2 prefix for T2 join columns  ( T2.A and T2.B ).
        , otherT2Columns = List.Difference( T2columnNames, T2joinColumns )             //T2 columns that are not used for join    ( C and Fact2 ).
        , duplicateT2otherColumns = List.Intersect( { T1columnNames, otherT2Columns } )            //T2 columns that are not used for join, but have the same name as some T1 columns  ( C ).
        , prefixDuplicateT2otherColumns = List.Transform( duplicateT2otherColumns, each "T2." & _ )         //above columns, but with T2 prefix ( T2.C ).    
        , nonDuplicateOtherColumns = List.Difference( otherT2Columns, duplicateT2otherColumns )  //non duplicate other columns ( Fact2 )
        , prefixNonDuplicateOthercolumns = List.Transform( nonDuplicateOtherColumns, each "T2." & _ )  // above with T2 prefix ( T2.Fact2 )
        //we now do the join
        , prefixT2table = Table.PrefixColumns( T2, "T2")
        , T1T2join = Table.Join( T1, T1joinColumns, prefixT2table, prefixT2joinColumns, JoinKind )         //we make a join
        //now we fix optional arguments    
        , PreserveT2joinColumnsOptional = if PreserveT2joinColumns = null then false else PreserveT2joinColumns   //because this is optional argument
        , PreserveT2duplicateOtherColumnsOptional = if PreserveT2duplicateOtherColumns = null then false else PreserveT2duplicateOtherColumns //because this is optional argument
        , PreservePrefixT2forNonDuplicateOtherColumnsOptional = if PreservePrefixT2forNonDuplicateOtherColumns = null then false else PreservePrefixT2forNonDuplicateOtherColumns // it is optional argument
        //now we delete columns, except if user doesn't want to. And we also remove T2 prefix from non duplicate other columns.
        , DeleteT2joinColumns = if PreserveT2joinColumnsOptional = true then T1T2join else Table.RemoveColumns( T1T2join, prefixT2joinColumns )
        , DeleteT2duplicateOtherColumns = if PreserveT2duplicateOtherColumnsOptional = true then DeleteT2joinColumns else Table.RemoveColumns( DeleteT2joinColumns, prefixDuplicateT2otherColumns )        
        , T2nonDuplicateOtherColumnsWithoutPrefix = if PreservePrefixT2forNonDuplicateOtherColumns = true then DeleteT2duplicateOtherColumns else Table.RenameColumns( DeleteT2duplicateOtherColumns, List.Zip( { prefixNonDuplicateOthercolumns, nonDuplicateOtherColumns }) )
      in
        T2nonDuplicateOtherColumnsWithoutPrefix

//Now we will create documentation for our function.    
    , fnDocumentatation = type function ( T1 as table, T1joinColumns as list, T2 as table, T2joinColumns as list, JoinKind as number, optional PreserveT2joinColumns as logical
                                                     , optional PreserveT2duplicateOtherColumns as logical, optional PreservePrefixT2forNonDuplicateOtherColumns as logical  ) as list meta  
        [ Documentation.Name = "fnEasyJoin"
          , Documentation.LongDescription = "This function will join two tables directly. There will be no problem with duplicate column names. All duplicate columns from Table 2 will be prefixed with ""T2."". After join, all duplicate
                                             columns from the Table 2, and all the columns from the Table 2 that are used for join, will be deleted. This is default behaviour.
                                             Last three arguments are optional and they can change default behaviour. First of those three can prevent Table 2 join columns to be deleted. Second can prevent other duplicates from Table 2 to be deleted.
                                             If those columns are not deleted they will have prefix T2. 
                                             Other non duplicate columns will not have prefix T2 by default. If we use third arugment of the last three arguments, we can change this also.
                                             For last three arguments boolean is ""FALSE"" by default. When changing behaviour, we change it to ""TRUE"" "
          , Documentation.Examples = { [ Description = "We have two tables, T1 and T2. First table has columns { ""A"", ""B"", ""C"", ""Fact1"" }. Second table has the same columns, just the name of the last column is ""Fact2"".
                                                        We will join these two columns based on join columns ""A"" and ""B"". Last three arguments will have default values. This means that columns T2.A, T2.B and T2.C will be deleted. Column T2.Fact2 will not
                                                        have prefix ""T2."" by default."
                                       , Code = "fnEasyJoin( #table( type table [A=text,B=text, C=text, Fact1=number], { { ""A1"", ""B1"", ""C1"", 50 }, { ""A2"", ""B2"", ""C2"", 200 } } ) 
          , { ""A"", ""B"" } 
          , #table( type table [A=text,B=text, C=text, Fact2=number], { { ""A1"", ""B1"", ""C1"", 3 }, { ""A2"", ""B2"", ""C2"", 700 } } )          
          , { ""A"", ""B"" }
          , JoinKind.Inner )"                                          
                                       , Result = "#table( type table [A=text,B=text,C=text,Fact1=number,Fact2=number]
      , { { ""A1"", ""B1"", ""C1"", 50, 3 }
      , { ""A2"", ""B2"", ""C2"", 200, 700 } } )"     ]  } ]
    , AddDocumentationToFunction = Value.ReplaceType( fnEasyJoin, fnDocumentatation )
    , Result = if true then AddDocumentationToFunction else T2nonDuplicateOtherColumnsWithoutPrefix     //by toggling true/false you can return function or procedure. Procedure is used for function development, because then you can see the steps in PQ GUI.
                                                                   //After you modify procedure, you place body of procedure inside of function. That is the easiest way of development.   
                
in
    Result
