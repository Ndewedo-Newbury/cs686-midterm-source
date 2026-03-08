#!/bin/bash
# Smoke test script for qa.cs686.live
# Usage: ./smoke-test.sh [base_url]
# Example: ./smoke-test.sh http://qa.cs686.live

BASE_URL="${1:-http://qa.cs686.live}"
API="$BASE_URL/api"
PASS=0
FAIL=0

green="\033[0;32m"
red="\033[0;31m"
reset="\033[0m"

pass() { echo -e "${green}[PASS]${reset} $1"; ((PASS++)); }
fail() { echo -e "${red}[FAIL]${reset} $1"; ((FAIL++)); }

check_status() {
  local label="$1"
  local expected="$2"
  local actual="$3"
  if [ "$actual" -eq "$expected" ]; then
    pass "$label (HTTP $actual)"
  else
    fail "$label (expected HTTP $expected, got HTTP $actual)"
  fi
}

echo "Running smoke tests against: $BASE_URL"
echo "----------------------------------------"

# 1. Frontend loads
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/")
check_status "Frontend loads" 200 "$STATUS"

# 2. GET /api/getArticles returns 200 with JSON array
RESPONSE=$(curl -s -w "\n%{http_code}" "$API/getArticles")
STATUS=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -1)
check_status "GET /api/getArticles" 200 "$STATUS"
if echo "$BODY" | grep -q '^\['; then
  pass "GET /api/getArticles returns JSON array"
else
  fail "GET /api/getArticles did not return a JSON array (got: $BODY)"
fi

# 3. GET /api/getReferences returns 200
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$API/getReferences")
check_status "GET /api/getReferences" 200 "$STATUS"

# 4. POST /api/addArticle creates an article
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API/addArticle" \
  -H "Content-Type: application/json" \
  -d '{"ArticleTitlu":"Smoke Test Article","ArticleRezumat":"Created by smoke test","ArticleData":"2026-01-01"}')
STATUS=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -1)
check_status "POST /api/addArticle" 201 "$STATUS"

ARTICLE_ID=$(echo "$BODY" | grep -o '"ArticleID":[0-9]*' | grep -o '[0-9]*')
if [ -n "$ARTICLE_ID" ]; then
  pass "POST /api/addArticle returned ArticleID=$ARTICLE_ID"
else
  fail "POST /api/addArticle did not return an ArticleID"
fi

# 5. GET /api/getArticleByID/:id retrieves the created article
if [ -n "$ARTICLE_ID" ]; then
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$API/getArticleByID/$ARTICLE_ID")
  check_status "GET /api/getArticleByID/$ARTICLE_ID" 200 "$STATUS"
fi

# 6. DELETE /api/deleteArticle/:id cleans up
if [ -n "$ARTICLE_ID" ]; then
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "$API/deleteArticle/$ARTICLE_ID")
  check_status "DELETE /api/deleteArticle/$ARTICLE_ID" 200 "$STATUS"
fi

echo "----------------------------------------"
echo -e "Results: ${green}$PASS passed${reset}, ${red}$FAIL failed${reset}"

[ "$FAIL" -eq 0 ] && exit 0 || exit 1
