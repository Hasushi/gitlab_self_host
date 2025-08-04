# GitLab Docker バックアップ設定

## 概要
このディレクトリには、Docker Composeで運用しているGitLabの週1回バックアップ設定が含まれています。

## バックアップ設定

### 1. 自動バックアップ（GitLab内蔵機能）
`docker-compose.yaml`で以下の設定を行っています：
- 毎週日曜日の午前2時に自動バックアップを実行
- バックアップは `/var/opt/gitlab/backups` に保存
- バックアップファイルは7日間保持

### 2. 手動バックアップスクリプト
`backup-gitlab.sh` スクリプトを使用して手動でバックアップを実行できます：

```bash
./backup-gitlab.sh

or

# Ubuntu
bash backup-gitlab.sh
```

### 3. cronジョブでの定期実行（オプション）
さらに確実にバックアップを取りたい場合は、ホストマシンのcronジョブを設定できます：

```bash
# crontabを編集
crontab -e

# 以下の行を追加（毎週日曜日の午前3時に実行）
0 3 * * 0 /Users/ikejimaren/Desktop/Prog/tmp/gitlab/backup-gitlab.sh
```

## バックアップファイルの場所
- バックアップファイル: `./srv/gitlab/data/backups/`
- ログファイル: `./backup.log`

## 現在のバックアップ状況の確認

### GitLabコンテナ内でのバックアップ実行
```bash
# GitLabコンテナに入る
docker exec -it gitlab_web_1 /bin/bash

# バックアップを手動実行
gitlab-backup create

# バックアップリストを確認
gitlab-backup list
```

### バックアップファイルの確認
```bash
# ローカルのバックアップディレクトリを確認
ls -la ./srv/gitlab/data/backups/
```

## 復元方法
バックアップからの復元が必要な場合：

```bash
# GitLabコンテナに入る
docker exec -it gitlab_web_1 /bin/bash

# GitLabサービスを停止
gitlab-ctl stop unicorn
gitlab-ctl stop puma
gitlab-ctl stop sidekiq

# バックアップから復元（BACKUP=タイムスタンプを指定）
gitlab-backup restore BACKUP=1754234892_2025_08_03_18.2.1

# GitLabを再起動
gitlab-ctl restart
```

## 注意事項
- GitLabの設定ファイル（`gitlab-secrets.json`など）は別途バックアップされていません
- 本格的な運用環境では、外部ストレージ（S3など）への自動アップロードも検討してください
- バックアップの動作テストを定期的に行うことを推奨します
