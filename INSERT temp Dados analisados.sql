delete from CLIENTE_DATA_TEMP_FILE;

INSERT INTO CLIENTE_DATA_TEMP_FILE (DATA,
                               RAZAO_SOCIAL,
                               NOME_FANTASIA,
                               CPF_CNPJ,
                               NOME_RESPONSAVEL,
                               ENDERECO,
                               TELEFONE,
                               WHATSAPP,
                               INVESTIMENTO,
                               EMAIL,
                               LINKEDIN,
                               CARGO,
                               SITE_WEB,
                               ID_EMPRESA_FK)
    (SELECT 
        NVL(CASE
                WHEN INSTR(col001, '/') = 2 THEN TO_DATE(col001, 'MM/DD/YYYY HH24:MI:SS')
                WHEN INSTR(col001, '/') = 3 THEN TO_DATE(col001, 'DD/MM/YYYY HH24:MI:SS')
                ELSE NULL
        END,SYSDATE) AS col001,
            col002,
            col003,
            col004,
            NVL(col005,'Nome não informado'),
            col006,
            col007,
            col008,
            col009,
            col010,
            col011,
            col012,
            col013,
            :GLOBAL_USER_EMPRESA
       FROM apex_application_temp_files f, apex_data_parser.parse      (
p_content => f.blob_content,
p_skip_rows => 1,
p_file_type => apex_data_parser.c_file_type_csv )
where f.name = :P19_FILE and 
      (col001 IS NOT NULL OR
      col002 IS NOT NULL OR
      col003 IS NOT NULL OR
      col004 IS NOT NULL OR
      col005 IS NOT NULL OR
      col006 IS NOT NULL OR
      col007 IS NOT NULL OR
      col008 IS NOT NULL OR
      col009 IS NOT NULL OR
      col010 IS NOT NULL OR
      col011 IS NOT NULL OR
      col012 IS NOT NULL OR
      col013 IS NOT NULL));
