#!/bin/bash

# GitLabバックアップスクリプト
# 使用方法: ./backup-gitlab.sh

# ログファイルの設定
LOG_FILE="/Users/ikejimaren/Desktop/Prog/tmp/gitlab/backup.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] GitLabバックアップを開始します..." | tee -a "$LOG_FILE"

# GitLabコンテナIDを取得
CONTAINER_NAME="gitlab-web-1"
CONTAINER_ID=$(docker ps -qf "name=$CONTAINER_NAME")

if [ -z "$CONTAINER_ID" ]; then
    echo "[$DATE] エラー: GitLabコンテナが見つかりません" | tee -a "$LOG_FILE"
    exit 1
fi

echo "[$DATE] GitLabコンテナID: $CONTAINER_ID" | tee -a "$LOG_FILE"

# バックアップの実行
echo "[$DATE] バックアップを実行中..." | tee -a "$LOG_FILE"
docker exec "$CONTAINER_ID" gitlab-backup create

if [ $? -eq 0 ]; then
    echo "[$DATE] バックアップが正常に完了しました" | tee -a "$LOG_FILE"
    
    # バックアップファイルのリストを表示
    echo "[$DATE] 現在のバックアップファイル:" | tee -a "$LOG_FILE"
    ls -la /Users/ikejimaren/Desktop/Prog/tmp/gitlab/srv/gitlab/data/backups/ | tee -a "$LOG_FILE"
    
    # 古いバックアップファイルの削除（7日より古いもの）
    echo "[$DATE] 古いバックアップファイルを削除中..." | tee -a "$LOG_FILE"
    find /Users/ikejimaren/Desktop/Prog/tmp/gitlab/srv/gitlab/data/backups/ -name "*.tar" -mtime +7 -delete
    
    echo "[$DATE] バックアップ処理が完了しました" | tee -a "$LOG_FILE"
else
    echo "[$DATE] エラー: バックアップに失敗しました" | tee -a "$LOG_FILE"
    exit 1
fi
