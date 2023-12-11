# Análise de Dados de Arquivo XLSX no Oracle APEX

Este script SQL realiza uma consulta para analisar dados de um arquivo XLSX armazenado temporariamente no Oracle APEX. Os dados são extraídos usando a função `apex_data_parser.parse` e, em seguida, são selecionadas colunas específicas da tabela resultante.

### Consulta SQL

```sql
SELECT line_number,
       col001,
       col002,
       col003,
       col004,
       col005,
       col006,
       col007,
       col008,
       col009,
       col010,
       col011,
       col012,
       col013
FROM apex_application_temp_files f, 
     TABLE(apex_data_parser.parse(
             p_content                     => f.blob_content,
             p_add_headers_row             => 'Y',
             p_xlsx_sheet_name             => :P19_XLSX_WORKSHEET,
             p_max_rows                    => 500,
             p_store_profile_to_collection => 'FILE_PARSER_COLLECTION',
             p_file_name                   => f.filename
          )) p
WHERE f.name = :P19_FILE 
  AND col001 IS NOT NULL 
  AND col002 IS NOT NULL 
  AND col003 IS NOT NULL 
  AND col004 IS NOT NULL 
  AND col005 IS NOT NULL 
  AND col006 IS NOT NULL;
```
## Dados Analisados
Relatório Clássico<br>
Tipo: Tabela/View<br>
Nome da Tabela: CLIENTE_DATA_TEMP_FILE<br>
## Processo Após a Análise
Após a análise desses dados, há um processo que insere os dados analisados em alguma tabela, possivelmente a tabela CLIENTE_DATA_TEMP_FILE.

# PL/SQL, operações de inserção e atualização
Esse código PL/SQL está realizando operações de inserção e atualização em duas tabelas, CLIENTE e CLIENTE_INFORMACAES, com base em dados provenientes da tabela CLIENTE_DATA_TEMP_FILE. Vamos analisar cada bloco:

Bloco 1 (Inserção de novos clientes):
```
DECLARE
   ID_CLIENTE_V NUMBER;
BEGIN
   FOR cliente_data IN (
      SELECT 
         CASE
            WHEN INSTR(F.DATA, '/') = 2 THEN TO_DATE(F.DATA, 'MM/DD/YYYY HH24:MI:SS')
            WHEN INSTR(F.DATA, '/') = 3 THEN TO_DATE(F.DATA, 'DD/MM/YYYY HH24:MI:SS')
            ELSE NULL
         END AS DATA,
         F.RAZAO_SOCIAL,
         F.NOME_RESPONSAVEL,
         F.WHATSAPP,
         F.INVESTIMENTO,
         F.EMAIL,
         F.ID_EMPRESA_FK,
         F.NOME_FANTASIA,
         F.CPF_CNPJ,
         F.ENDERECO,
         F.TELEFONE,
         F.LINKEDIN,
         F.CARGO,
         F.SITE_WEB
      FROM CLIENTE_DATA_TEMP_FILE F
      LEFT JOIN CLIENTE A ON A.WHATSAPP = F.WHATSAPP
      LEFT JOIN CLIENTE_INFORMACAES C ON C.ID_CLIENTE_FK = A.ID
      WHERE A.WHATSAPP IS NULL
   ) LOOP
      BEGIN
         INSERT INTO CLIENTE (
            CARIMBO_DE_DATA_HORA,
            NOME,
            WHATSAPP,
            VALOR_DE_INVESTIMENTO,
            GMAIL,
            ID_EMPRESA_FK
         ) VALUES (
            NVL(cliente_data.DATA, SYSDATE),
            NVL(DECODE(cliente_data.NOME_RESPONSAVEL, NULL, cliente_data.RAZAO_SOCIAL, cliente_data.NOME_RESPONSAVEL), 'Nome não informado'),
            cliente_data.WHATSAPP,
            cliente_data.INVESTIMENTO,
            cliente_data.EMAIL,
            cliente_data.ID_EMPRESA_FK
         )
         RETURNING ID INTO ID_CLIENTE_V;

         INSERT INTO CLIENTE_INFORMACAES (
            ID_CLIENTE_FK,
            "NOME/RAZAO_SOCIAL",
            FANTASIA,
            "CNPJ/CPF",
            FONE_CONTATO,
            LINKEDIN,
            NOME_CONTATO,
            CARGO_COBTATO,
            ENDERECO,
            EMAIL,
            SITE_WEB,
            ID_EMPRESA_FK
         ) VALUES (
            ID_CLIENTE_V,
            cliente_data.RAZAO_SOCIAL,
            cliente_data.NOME_FANTASIA,
            cliente_data.CPF_CNPJ,
            cliente_data.TELEFONE,
            cliente_data.LINKEDIN,
            cliente_data.NOME_RESPONSAVEL,
            cliente_data.CARGO,
            cliente_data.ENDERECO,
            cliente_data.EMAIL,
            cliente_data.SITE_WEB,
            cliente_data.ID_EMPRESA_FK
         );

      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   END LOOP;
   COMMIT;
END;

```
Bloco 2 (Atualização de clientes existentes):
```
DECLARE
   ID_CLIENTE_V NUMBER;
BEGIN
   FOR cliente_data IN (
      SELECT 
         CASE
            WHEN INSTR(F.DATA, '/') = 2 THEN TO_DATE(F.DATA, 'MM/DD/YYYY HH24:MI:SS')
            WHEN INSTR(F.DATA, '/') = 3 THEN TO_DATE(F.DATA, 'DD/MM/YYYY HH24:MI:SS')
            ELSE NULL
         END AS DATA,
         F.RAZAO_SOCIAL,
         F.NOME_RESPONSAVEL,
         F.WHATSAPP,
         F.INVESTIMENTO,
         F.EMAIL,
         F.ID_EMPRESA_FK,
         F.NOME_FANTASIA,
         F.CPF_CNPJ,
         F.ENDERECO,
         F.TELEFONE,
         F.LINKEDIN,
         F.CARGO,
         F.SITE_WEB
      FROM CLIENTE_DATA_TEMP_FILE F
      LEFT JOIN CLIENTE A ON A.WHATSAPP = F.WHATSAPP
      LEFT JOIN CLIENTE_INFORMACAES C ON C.ID_CLIENTE_FK = A.ID
      WHERE A.WHATSAPP IS NOT NULL
   ) LOOP
      BEGIN
         UPDATE CLIENTE SET 
            CARIMBO_DE_DATA_HORA = cliente_data.DATA,
            NOME = DECODE(cliente_data.NOME_RESPONSAVEL, NULL, cliente_data.RAZAO_SOCIAL, cliente_data.NOME_RESPONSAVEL),
            WHATSAPP = cliente_data.WHATSAPP,
            VALOR_DE_INVESTIMENTO = cliente_data.INVESTIMENTO,
            GMAIL = cliente_data.EMAIL,
            ID_EMPRESA_FK = cliente_data.ID_EMPRESA_FK
         WHERE WHATSAPP = cliente_data.WHATSAPP
         RETURNING ID INTO ID_CLIENTE_V;

         UPDATE CLIENTE_INFORMACAES SET
            "NOME/RAZAO_SOCIAL" = cliente_data.RAZAO_SOCIAL,
            FANTASIA = cliente_data.NOME_FANTASIA,
            "CNPJ/CPF" = cliente_data.CPF_CNPJ,
            FONE_CONTATO = cliente_data.TELEFONE,
            LINKEDIN = cliente_data.LINKEDIN,
            NOME_CONTATO = cliente_data.NOME_RESPONSAVEL,
            CARGO_COBTATO = cliente_data.CARGO,
            ENDERECO = cliente_data.ENDERECO,
            EMAIL = cliente_data.EMAIL,
            SITE_WEB = cliente_data.SITE_WEB,
            ID_EMPRESA_FK = cliente_data.ID_EMPRESA_FK
         WHERE ID_CLIENTE_FK = ID_CLIENTE_V;

      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   END LOOP;
   COMMIT;
END;

```
Esses blocos estão basicamente processando os dados da tabela CLIENTE_DATA_TEMP_FILE e realizando inserções ou atualizações nas tabelas CLIENTE e CLIENTE_INFORMACAES com base nas condições especificadas.
