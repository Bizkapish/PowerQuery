let
    ColumnName = "Date"
    , Source = #table( type table [ Date=date, Number=number ], { { #date(2030,1,1), 1 }, { #date(2029,1,1), 1 }, { #date(2028,1,1), 1 } } )
    , LastDate = List.Max( Table.Column( Source, ColumnName ) )    
    , RecordsWithLastDate = Table.SelectRows( Source, each Record.Field( _ , ColumnName ) = LastDate )
    , fnRecordsWithLastDate = ( Source as table, ColumnName as text ) as table =>
        let 
            LastDate = List.Max( Table.Column( Source, ColumnName ) )    
            , RecordsWithLastDate = Table.SelectRows( Source, each Record.Field( _ , ColumnName ) = LastDate )
        in RecordsWithLastDate
//Now we will create documentation for our function.    
    , fnDocumentatation = type function ( source as table, ColumnName as text ) as list meta  
        [ Documentation.Name = "fnRecordsWithLastDate"
          , Documentation.LongDescription = "This function will accept a table and a column name. It is assumed that column has Date data type. This table will be filtered by the biggest date from Date type column."
          , Documentation.Examples = { [ Description = "We have Table ""#table( type table [ Date=date, Number=number ], { { #date(2030,1,1), 1 }, { #date(2029,1,1), 1 }, { #date(2028,1,1), 1 } } )"".
          This table will be filtered by the biggest date and that is 01.01.2030. Only rows with this date will survive filter."
                                       , Code = "fnRecordsWithLastDate( #table( type table [ Date=date, Number=number ], { { #date(2030,1,1), 1 }, { #date(2029,1,1), 1 }, { #date(2028,1,1), 1 } } ), ""Date"" )" 
                                       , Result = "#table( type table [ Date=date, Number=number ], { { #date(2030,1,1), 1 } } )"  ] }
        ]                               
    , AddDocumentationToFunction = Value.ReplaceType( fnRecordsWithLastDate, fnDocumentatation )
    , Result = if true then AddDocumentationToFunction else RecordsWithLastDate  //by toggling true/false you can return function or procedure. Procedure is used for function development
                          //, because then you can see the steps in PQ GUI. After you modify procedure, you place body of procedure inside of function. That is the easiest way of development.   
                
in
    Result
