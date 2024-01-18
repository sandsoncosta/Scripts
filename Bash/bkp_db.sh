#!/bin/bash

# Este script faz o bkp dos dbs do mysql, salva em um temp dir e
# faz a compressão para um arquivo tar.gz.
# Ele inclui a info de sucesso ou não em uma tabela informando o resultado
# positivo ou negativo.
# O script é uma compreensão básica de execução, podendo ter infinitas melhorias.

# Configurações de login do DB
DB_USER="login"
DB_PASSWORD="password"

# Setando os bancos a serem realizados o backup
DB_NAMES=("sakila" "mysql")

# Caminho pra salvar o bkp
BKP_DIR="/home"

# Diretório temporário
TEMP_DIR="/tmp/backups"

# Fazer o dir temp
mkdir -p $TEMP_DIR

# Vai começar a brincadeira...
for DB_NAME in "${DB_NAMES[@]}"; do

  # nome do arquivo de saída
  BKP_FILENAME="$DB_NAME-$(date +\%Y\%m\%d\%H\%M\%S).sql"

  # Comando de bkp do banco
  mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > $TEMP_DIR/$BKP_FILENAME 2>/dev/null

  # Validando o banco
  if [ $? -eq 0 ]; then
    echo "Backup do banco de dados $DB_NAME foi criado com sucesso em $TEMP_DIR/$BKP_FILENAME"

    # inserir um log de concluído ou erro
    mysql -u $DB_USER -p$DB_PASSWORD -e "INSERT INTO log_backup.log_backup (status) VALUES ('Backup do banco de dados $DB_NAME concluído com sucesso');"
  
  else
    echo "Erro ao criar o backup do banco de dados $DB_NAME"

    # inserir um log de erro 
    mysql -u $DB_USER -p$DB_PASSWORD -e "INSERT INTO log_backup.log_backup (status) VALUES ('Erro ao criar o backup do banco de dados $DB_NAME');"
  fi
done

COMPRESS_BKP="backups-$(date +\%Y\%m\%d\%H\%M\%S).tar.gz"
tar -czvf $BACKUP_DIR/$COMPRESS_BKP -C $TEMP_DIR .

# Remover arquivos do /tmp
rm -rf $TEMP_DIR

echo "Backups comprimidos com sucesso em $BKP_DIR"
