#!/bin/bash
set -e

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use default

npm install --global corepack
corepack enable
corepack prepare yarn@1.x --activate
corepack prepare pnpm@latest --activate

YARN_BIN_PATH="$(yarn global bin)"
if ! grep -q "yarn global bin" ~/.zshrc 2>/dev/null; then
    echo "" >> ~/.zshrc
    echo "# Yarn global bin" >> ~/.zshrc
    echo "export PATH=\"\$PATH:$YARN_BIN_PATH\"" >> ~/.zshrc
fi
export PATH="$PATH:$(yarn global bin)"

yarn global add pm2
pm2 completion install

echo "✅ Node.js setup hoàn tất!"
echo "📦 Node.js version: $(node --version)"
echo "📦 npm version: $(npm --version)"
echo "📦 yarn version: $(yarn --version)"
echo "📦 pnpm version: $(pnpm --version)"
echo "📦 pm2 version: $(pm2 --version)"
