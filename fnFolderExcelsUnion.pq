let
//This is just procedure for easier development. At the top we have test data. Replace those test date with values that are valid for your computer.
    FolderFullPath = "O:\10. Power Query Samples\fnFolderExcelsUnion"  //FolderFullPath is path to folder with Excel files.
    , GetFileDateAttributes = true //'GetFileDateAttributes = true' means that we want to preserve date of access, creation and modification for each file.
    , ExcelTableNames = { "SampleTable1", "SampleTable2" }  //ExcelTableNames is a list of Excel table names from which we want to take data. 
    , FilesFilter = "each Text.Contains( [Name], ""2"" )"  //we can filter files by supplying custom filter
//Bellow is the procedure we use for development. If that procedure is OK, we will copy it as the body of the function.        
        , GetFolderFiles = Folder.Files( FolderFullPath )
        , FilterFiles = if FilesFilter <> null then Table.SelectRows( GetFolderFiles, Expression.Evaluate( FilesFilter, #shared ) ) else GetFolderFiles //we can filter only files that we need
        , CAddTOC = Table.AddColumn( FilterFiles, "CAddTOC", each Excel.Workbook( [Content] ) )
        , CAddTabelix = Table.AddColumn( CAddTOC, "CAddTabelix", each Table.Combine( Table.SelectRows( [CAddTOC], each List.Contains( ExcelTableNames, [Item] ) )[Data] ) )  //in previous lines we took Excel files, then their content, then our tables.
        , AddcFileName = Table.AddColumn( CAddTabelix, "AddcFileName", each let FileName = [Name], Res = Table.AddColumn( [CAddTabelix], "File name", each FileName ) in Res )  //we will always preserve name of files.
        , CAddDateAttributesRecord = if GetFileDateAttributes = false then AddcFileName else Table.AddColumn( AddcFileName, "CAddDateAttributesRecord", each [Date accessed = [Date accessed], Date modified = [Date modified], Date created = [Date created] ] )
        , AddcDateAttributes = if GetFileDateAttributes = false then CAddDateAttributesRecord else Table.AddColumn( CAddDateAttributesRecord, "AddcDateAttributes", each 
            let DateAttributes = [CAddDateAttributesRecord], Res = Table.TransformRows( [AddcFileName], each _ & DateAttributes ) in Table.FromRecords( Res ) )  //we preserve dates if GetFileDateAttributes = true.
        , MakeUnion = Table.Combine( if GetFileDateAttributes = false then AddcFileName[AddcFileName] else AddcDateAttributes[AddcDateAttributes] )  //At the end we combine all Tables into one.

//now we create our function. We will first develop body of a function by using procedure above, and then we will copy that body into our function.
    , fnFolderExcelsUnion = ( FolderFullPath as text, ExcelTableNames as list, GetFileDateAttributers as logical, optional FilesFilter as text ) as table => 
      let
        GetFolderFiles = Folder.Files( FolderFullPath )
        , FilterFiles = if FilesFilter <> null then Table.SelectRows( GetFolderFiles, Expression.Evaluate( FilesFilter, #shared ) ) else GetFolderFiles //we can filter only files that we need
        , CAddTOC = Table.AddColumn( FilterFiles, "CAddTOC", each Excel.Workbook( [Content] ) )
        , CAddTabelix = Table.AddColumn( CAddTOC, "CAddTabelix", each Table.Combine( Table.SelectRows( [CAddTOC], each List.Contains( ExcelTableNames, [Item] ) )[Data] ) )  //in previous lines we took Excel files, then their content, then our tables.
        , AddcFileName = Table.AddColumn( CAddTabelix, "AddcFileName", each let FileName = [Name], Res = Table.AddColumn( [CAddTabelix], "File name", each FileName ) in Res )  //we will always preserve name of files.
        , CAddDateAttributesRecord = if GetFileDateAttributes = false then AddcFileName else Table.AddColumn( AddcFileName, "CAddDateAttributesRecord", each [Date accessed = [Date accessed], Date modified = [Date modified], Date created = [Date created] ] )
        , AddcDateAttributes = if GetFileDateAttributes = false then CAddDateAttributesRecord else Table.AddColumn( CAddDateAttributesRecord, "AddcDateAttributes", each 
            let DateAttributes = [CAddDateAttributesRecord], Res = Table.TransformRows( [AddcFileName], each _ & DateAttributes ) in Table.FromRecords( Res ) )  //we preserve dates if GetFileDateAttributes = true.
        , MakeUnion = Table.Combine( if GetFileDateAttributes = false then AddcFileName[AddcFileName] else AddcDateAttributes[AddcDateAttributes] )  //At the end we combine all Tables into one.
      in        
        MakeUnion

//Now we can create documentation:
    , fnDocumentatation = type function ( FolderFullPath as text, ExcelTableNames as list, GetFileDateAttributers as logical, optional FilesFilter as text ) as list meta  
        [ Documentation.Name = "fnFolderExcelsUnion"
          , Documentation.LongDescription = "You have a folder with several Excel files. You can get all the files from that folder or you can supply last argument in order to filter only some of the files.
                                             Each Excel file has declared tables with the names from 'ExcelTableNames' list. We want to collect data from all those tables. We can use this function for that.
                                             Each table will get a column with the name of file from which that table is. If 'GetFileDateAttributes' = true then dates of modification, creation and access will also be added to each table as columns.
                                             At the end we will make a union of all the tables because they have the same structure."
          , Documentation.Examples = { [ Description = "From folder 'FolderFullPath' get all Excel files that have 'SampleFile' in their names, read declared tables inside them named like in 'ExcelTableNames' list, and then make a union of them."
                                       , Code = "fnFolderExcelsUnion( FolderFullPath, true, ExcelTableNames, ""each Text.Contains( [Name], ""SampleFile"" )"" )"
                                       , Result = "a union of 'ExcelTableNames' tables. Union will have columns 'File name', 'Date accessed', 'Date modified', 'Date created' appended." ]  } ]
    , AddDocumentationToFunction = Value.ReplaceType( fnFolderExcelsUnion, fnDocumentatation )    

//by changing true to false, and vice versa, we can transform this query from procedure to the function.
    , Res = if true then AddDocumentationToFunction else MakeUnion        
in
    Res
