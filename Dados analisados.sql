select line_number, col001, col002, col003, col004, col005 , col006, col007, col008, col009, col010, col011, col012, col013
  from apex_application_temp_files f, 
       table( apex_data_parser.parse(
                  p_content                     => f.blob_content,
                  p_add_headers_row             => 'Y',
                  p_xlsx_sheet_name             => :P19_XLSX_WORKSHEET,
                  p_max_rows                    => 500,
                  p_store_profile_to_collection => 'FILE_PARSER_COLLECTION',
                  p_file_name                   => f.filename ) ) p
 where f.name = :P19_FILE and col001 is not null and col001 is not null and col002 is not null and col003 is not null and col004 is not null and col005 is not null and col006 is not null
