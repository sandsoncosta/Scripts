#!/bin/bash

# Diretório de origem dos arquivos de vídeo
diretorio_origem="/home/sandson/Downloads/Video/"

# Diretório de destino para os arquivos convertidos
diretorio_destino="/home/sandson/Downloads/Video/"

# Formato de saída desejado (por exemplo, "mp4" ou "avi")
formato_saida="mp4"

# Iterar sobre os arquivos de vídeo no diretório de origem
for arquivo_origem in "${diretorio_origem}"/*; do
    if [ -f "$arquivo_origem" ]; then
        # Obter o nome do arquivo sem a extensão
        nome_arquivo_sem_extensao=$(basename "${arquivo_origem%.*}")
        
        # Construir o nome do arquivo de destino com o novo formato
        arquivo_destino="${diretorio_destino}/${nome_arquivo_sem_extensao}.${formato_saida}"
        
        # Comando FFmpeg para converter o arquivo de origem para o formato de destino
        ffmpeg -i "$arquivo_origem" -c copy "$arquivo_destino"
        
        echo "Arquivo convertido: $arquivo_destino"
    fi
done

echo "Conversão concluída."