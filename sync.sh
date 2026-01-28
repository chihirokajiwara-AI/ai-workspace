#!/bin/bash
# sync.sh - 全プロジェクト同期スクリプト
# Usage: ./sync.sh [pull|push|status]

set -e

DEV_DIR="$HOME/dev"
ACTION="${1:-pull}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "$DEV_DIR"

case "$ACTION" in
  pull)
    echo -e "${BLUE}=== 全プロジェクトを pull ===${NC}"
    for dir in */; do
      if [ -d "$dir/.git" ]; then
        echo -e "${GREEN}▶ $(basename $dir)${NC}"
        cd "$dir"
        git pull --rebase 2>/dev/null || git pull || echo -e "${YELLOW}  (変更なし or エラー)${NC}"
        cd ..
      fi
    done
    echo -e "${GREEN}✓ 完了${NC}"
    ;;
    
  push)
    echo -e "${BLUE}=== 全プロジェクトを push ===${NC}"
    for dir in */; do
      if [ -d "$dir/.git" ]; then
        cd "$dir"
        if [ -n "$(git status --porcelain)" ]; then
          echo -e "${GREEN}▶ $(basename $dir)${NC}"
          git add -A
          git commit -m "Auto-sync from $(hostname)" || true
          git push
        else
          echo -e "${YELLOW}▷ $(basename $dir) (変更なし)${NC}"
        fi
        cd ..
      fi
    done
    echo -e "${GREEN}✓ 完了${NC}"
    ;;
    
  status)
    echo -e "${BLUE}=== 全プロジェクトの状態 ===${NC}"
    for dir in */; do
      if [ -d "$dir/.git" ]; then
        cd "$dir"
        changes=$(git status --porcelain | wc -l | tr -d ' ')
        if [ "$changes" -gt 0 ]; then
          echo -e "${YELLOW}● $(basename $dir) - ${changes}件の変更${NC}"
        else
          echo -e "${GREEN}✓ $(basename $dir) - クリーン${NC}"
        fi
        cd ..
      fi
    done
    ;;
    
  *)
    echo "Usage: $0 [pull|push|status]"
    echo ""
    echo "  pull   - 全プロジェクトの最新を取得（デフォルト）"
    echo "  push   - 変更のある全プロジェクトをpush"
    echo "  status - 全プロジェクトの状態を確認"
    exit 1
    ;;
esac
