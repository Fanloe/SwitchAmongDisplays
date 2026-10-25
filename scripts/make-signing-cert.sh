#!/usr/bin/env bash
# 生成发布用的自签名代码签名证书。
#
# 为什么要固定证书：macOS 的辅助功能授权（TCC）绑定代码签名。ad-hoc 签名每次
# 构建都不同，用户每次更新都要重新授权；固定证书的 designated requirement 只
# 认证书，所以一次授权长期有效。
#
# 输出在 signing/ 下，其中只有 cert.pem（公钥证书）会提交到仓库，
# key.pem / cert.p12 / p12-password.txt 是机密，必须在 .gitignore 中排除。
# 丢失 key.pem 会导致所有已安装用户下次更新时重新授权，请务必备份 signing/。

set -euo pipefail
cd "$(dirname "$0")/.."

CN="SwitchAmongDisplays Self-Signed"
DIR="signing"

OPENSSL=openssl
if ! "$OPENSSL" version 2>/dev/null | grep -q '^OpenSSL 3'; then
    if command -v brew >/dev/null && [ -x "$(brew --prefix openssl@3 2>/dev/null)/bin/openssl" ]; then
        OPENSSL="$(brew --prefix openssl@3)/bin/openssl"
    else
        echo "错误：需要 OpenSSL 3（macOS 自带的是 LibreSSL）。请先运行：brew install openssl@3" >&2
        exit 1
    fi
fi

if [ -e "$DIR/key.pem" ]; then
    echo "错误：$DIR/key.pem 已存在，拒绝覆盖。" >&2
    echo "轮换证书会让所有已安装用户重新授权；如确需轮换，先手动移走 $DIR/。" >&2
    exit 1
fi

umask 077
mkdir -p "$DIR"
PASS=$("$OPENSSL" rand -base64 32 | tr -dc 'A-Za-z0-9' | head -c 24)

"$OPENSSL" req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes \
    -keyout "$DIR/key.pem" -out "$DIR/cert.pem" \
    -subj "/CN=$CN" \
    -addext "basicConstraints=critical,CA:false" \
    -addext "keyUsage=critical,digitalSignature" \
    -addext "extendedKeyUsage=critical,codeSigning"

# macOS 的 security import 不认 OpenSSL 3 默认的 PKCS#12 加密算法，必须 -legacy
"$OPENSSL" pkcs12 -export -legacy \
    -inkey "$DIR/key.pem" -in "$DIR/cert.pem" \
    -name "$CN" -out "$DIR/cert.p12" -passout "pass:$PASS"

printf '%s' "$PASS" > "$DIR/p12-password.txt"
base64 -i "$DIR/cert.p12" | tr -d '\n' > "$DIR/cert.p12.base64"

echo "已生成："
echo "  $DIR/cert.pem           （公开证书，提交到仓库）"
echo "  $DIR/key.pem            （私钥，务必离线备份）"
echo "  $DIR/cert.p12           （证书+私钥，导入 CI 用）"
echo "  $DIR/cert.p12.base64    （GitHub Secret SIGNING_CERT_P12 的值）"
echo "  $DIR/p12-password.txt   （GitHub Secret SIGNING_CERT_PASSWORD 的值）"
echo
echo "接下来设置 GitHub Secrets（需先 gh auth login）："
echo "  gh secret set SIGNING_CERT_P12 < $DIR/cert.p12.base64"
echo "  gh secret set SIGNING_CERT_PASSWORD < $DIR/p12-password.txt"
