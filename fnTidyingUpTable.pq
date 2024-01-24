let
//This is for development and testing. Read the comment at the bottom. Real function is bellow.
    Tabelix = #table( type table [A=text,B=text,C=text,D=text,E=text,F=text, G=text, H=text, I=text, J=text], { { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J" }, { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J" } } )      //these are sample data
    , ToDelete = { "A", "B"}
    , ToStart = { "I", "J" }
    , ToEnd = { "C", "D" }
    , ToRename = { { "I", "I1" }, { "J", "J1" }, { "C", "C1" }, { "D", "D1" } }
//Body: First we fix situations where we are missing some arguments. In that case we would use empty lists.
    , ToDeleteIfNull = if ToDelete = null then { } else ToDelete
    , ToStartIfNull = if ToStart = null then { } else ToStart
    , ToEndIfNull = if ToEnd = null then { } else ToEnd
    , ToRenameIfNull = if ToRename = null then { } else ToRename
//This will delete some columns. Some columns will be placed on start, some on end. Maybe we will rename some columns.    
    , WeDeleteSomeColumns = Table.RemoveColumns( Tabelix, ToDeleteIfNull, MissingField.Ignore )
    , WeReorderSomeColumns = Table.ReorderColumns( WeDeleteSomeColumns, ToStartIfNull & List.RemoveItems( Table.ColumnNames( Tabelix ), ToStartIfNull & ToEndIfNull ) & ToEndIfNull, MissingField.Ignore )
    , WeRenameSomeColumns = Table.RenameColumns( WeReorderSomeColumns, ToRenameIfNull, MissingField.Ignore )

//lets make a function from this body. This function has the same body as above.
    , funcTidyingUpTable = ( Tabelix as table, optional ToDelete as list, optional ToStart as list, optional ToEnd as list, optional ToRename as list  ) as table  => 
      let 
        //Body: First we fix situations where we are missing some arguments. In that case we would use empty lists.
        ToDeleteIfNull = if ToDelete = null then { } else ToDelete
        , ToStartIfNull = if ToStart = null then { } else ToStart
        , ToEndIfNull = if ToEnd = null then { } else ToEnd
        , ToRenameIfNull = if ToRename = null then { } else ToRename
        //This will delete some columns. Some columns will be placed on start, some on end. Maybe we will rename some columns.    
        , WeDeleteSomeColumns = Table.RemoveColumns( Tabelix, ToDeleteIfNull, MissingField.Ignore )
        , WeReorderSomeColumns = Table.ReorderColumns( WeDeleteSomeColumns, ToStartIfNull & List.RemoveItems( Table.ColumnNames( Tabelix ), ToStartIfNull & ToEndIfNull ) & ToEndIfNull, MissingField.Ignore )
        , WeRenameSomeColumns = Table.RenameColumns( WeReorderSomeColumns, ToRenameIfNull, MissingField.Ignore )    
      in
        WeRenameSomeColumns

//Now we will create documentation for our function.    
    , fnDocumentatation = type function ( TableToTidyUp as table, optional ToDelete as list, optional ToStart as list, optional ToEnd as list, optional ToRename as list ) as list meta  
        [ Documentation.Name = "fnTidyingUpTable"
          , Documentation.LongDescription = "This function will replace several other simpler functions at once. It will delete some columns. It will reorder some columns by placing them on the beginning or at the end.
                                             It will rename some columns. All arguments are optional."
          , Documentation.Examples = { [ Description = "We have table with columns A,B,C,D,I,F,G,I,J. We will delete columns {""A"",""B"" }. We will reorder columns { ""I"", ""J"" } on start. Columns { ""C"", ""D"" } will go to end. 
                                                        We will rename some of the columns.  Each of columns { ""I"", ""J"", ""C"", ""D"" } will get sufix ""1"" { ""I1"", ""J1"", ""C1"", ""D1"" } as a new name."
                                       , Code = "fnTidyingUpTable( 
                                                  #table( type table [A=text,B=text,C=text,D=text,E=text,F=text, G=text, H=text, I=text, J=text]
                                                                    , { { ""A"", ""B"", ""C"", ""D"", ""E"", ""F"", ""G"", ""H"", ""I"", ""J"" }
                                                                      , { ""A"", ""B"", ""C"", ""D"", ""E"", ""F"", ""G"", ""H"", ""I"", ""J"" } }    )
                                                        , { ""A"", ""B""}   //for deletion
                                                        , { ""I"", ""J"" }   //will be placed on beginning
                                                        , { ""C"", ""D"" }   //will be placed on end
                                                        , { { ""I"", ""I1"" }, { ""J"", ""J1"" }, { ""C"", ""C1"" }, { ""D"", ""D1"" } } )    //will be renamed"
                                       , Result = "#table( type table [I1=text,J1=text,E=text,F=text,G=text,H=text, C1=text, D1=text]
                                                                    , { { ""I"", ""J"", ""E"", ""F"", ""G"", ""H"", ""C"", ""D"" }
                                                                      , { ""I"", ""J"", ""E"", ""F"", ""G"", ""H"", ""C"", ""D"" } } )"     ]  } ]
    , AddDocumentationToFunction = Value.ReplaceType( funcTidyingUpTable, fnDocumentatation )
    , Result = if true then AddDocumentationToFunction else WeRenameSomeColumns     //by toggling true/false you can return function or procedure. Procedure is used for function development, because then you can see the steps in PQ GUI.
                                                                   //After you modify procedure, you place body of procedure inside of function. That is the easiest way of development.   
                
in
    Result