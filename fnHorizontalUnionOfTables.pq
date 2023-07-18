let
//This is for development and testing. Read the comment at the bottom. Real function is bellow.
        Tab1 = #table( type table [A=number], { { 1 }, { 2 } } )      //these are sample data
        , Tab2 = #table( { "B" }, { { 3 }, { 4 }, { 5 } } )
        , Tab3 = #table( { "A" }, { { 1 }, { 2 } } )
        , ListOfTables = { Tab1, Tab2, Tab3 }
//Body: This will join tables horizontally, first row to first row, second row to second row etc.
        , GetColumnTypes = List.Transform( ListOfTables, each Table.Schema( _ ) )     //first we will get list of column types. We need them because transpose function will delete them.
        , GetDistinctTypes = Table.Distinct( Table.Combine( GetColumnTypes ), "Name" )[Kind]     //some columns are duplicate, we remove them, only the first column will remain.
        , TransformToRealTypes = List.Transform( GetDistinctTypes, each Expression.Evaluate( "type " & _ ) )  //we need types as objects. We achive that with Expression.Evaluate.
        , DemoteColumnNames = List.Transform( ListOfTables, each Table.DemoteHeaders( _ ) )   //tranpose function will lose column names, too. So, we will preserve them as a row.
        , TransposeEachTable = List.Transform( DemoteColumnNames, each Table.Transpose( _ ) )   //we use transpose to convert join to union.
        , Union = Table.Combine( TransposeEachTable )
        , RemoveDuplicateColumns = Table.Distinct( Union, "Column1")    //again we will remove duplicate columns. Before we removed duplicate columns as types, now we remove their data.
        , TransposeBack = Table.PromoteHeaders( Table.Transpose( RemoveDuplicateColumns ) )
        , ApplyTypesBack = Table.TransformColumnTypes( TransposeBack, List.Zip( { Table.ColumnNames( TransposeBack ), TransformToRealTypes } ) )
//lets make a function from this body.
    , funcHorizontalUnionOfTables = ( ListOfTables as list ) as table  => 
      let 
          GetColumnTypes = List.Transform( ListOfTables, each Table.Schema( _ ) ) 
        , GetDistinctTypes = Table.Distinct( Table.Combine( GetColumnTypes ), "Name" )[Kind]     //some columns are duplicate, we remove them, only the first column will remain.
        , TransformToRealTypes = List.Transform( GetDistinctTypes, each Expression.Evaluate( "type " & _ ) )  //we need types as objects. We achive that with Expression.Evaluate.
        , DemoteColumnNames = List.Transform( ListOfTables, each Table.DemoteHeaders( _ ) )    
        , TransposeEachTable = List.Transform( DemoteColumnNames, each Table.Transpose( _ ) )    
        , Union = Table.Combine( TransposeEachTable )
        , RemoveDuplicateColumns = Table.Distinct( Union, "Column1")    //again we will remove duplicate columns. Before we remove duplicate columns as types, now we remove their data.
        , TransposeBack = Table.PromoteHeaders( Table.Transpose( RemoveDuplicateColumns ) )
        , ApplyTypesBack = Table.TransformColumnTypes( TransposeBack, List.Zip( { Table.ColumnNames( TransposeBack ), TransformToRealTypes } ) )
      in
        ApplyTypesBack
//Now we will create documentation for our function.    
    , fnDocumentatation = type function ( ListOfTables as list ) as list meta  
        [ Documentation.Name = "fnHorizontalUnionOfTables"
          , Documentation.LongDescription = "This function will glue tables horizontaly. It is like a join, but rows are joined by their position (1-1,2-2...). 
                                             If first table has 10 rows and 2 columns, second table has 10 rows and 3 columns, final table will have 10 rows and 5 columns.
                                             We can glue more than two tables together.
                                             If some tables have columns with the same name, only first column with such name will remain, others will be removed.
                                             Tables dont need to have the same number of rows. Orphan rows will be filled with nulls."
          , Documentation.Examples = { [ Description = "We have left and right table. They don't have the same number of rows. Lets glue them together."
                                       , Code = "fnHorizontalUnion( #table( { ""A"" }, {{ ""Apple"" }, { ""Pear"" }} ), #table( { ""B"" }, {{ ""Orange"" }} ) )"
                                       , Result = "#table( { ""A"", ""B"" }, {{ ""Apple"", ""Orange"" }, { ""Pear"", null }} )" ]  } ]
    , AddDocumentationToFunction = Value.ReplaceType( funcHorizontalUnionOfTables, fnDocumentatation )
    , Result = if true then AddDocumentationToFunction else ApplyTypesBack    //by toggling true/false you can return function or procedure. Procedure is used for function development. 
                                                                   //After you modify procedure, you place body of procedure inside of function. That is the easiest way of development.    
in
    Result
