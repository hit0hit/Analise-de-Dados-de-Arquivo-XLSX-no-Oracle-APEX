select column_position, column_name, data_type, format_mask
  from apex_collections c, 
       table( apex_data_parser.get_columns( p_profile => c.clob001 ) )
 where c.collection_name = 'FILE_PARSER_COLLECTION' 
   and c.seq_id = 1
