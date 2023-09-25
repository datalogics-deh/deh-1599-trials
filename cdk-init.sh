#!/usr/bin/env bash

# https://stackoverflow.com/a/246128/11996393
here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

cd "$here" || exit 1

tmpdir="$(mktemp -d)"
trap 'rm -rf -- "$tmpdir"' EXIT

set -e

curdirname=${PWD##*/}       # to assign to a variable
curdirname=${curdirname:-/} # to correct for the case where PWD=/

initdir="$tmpdir/$curdirname"

mkdir -p "$initdir"

echo "1️⃣  Running 'cdk init'..."
(cd "$initdir" && cdk init --generate-only "$@")

if ! grep -q '^# CDK$' .gitignore; then
    echo "Updating .gitignore..."

    cat >> .gitignore << EOF

# CDK
EOF
    cat "$initdir/.gitignore" >> .gitignore
fi

echo "2️⃣  Importing CDK dependencies into pyproject.toml..."
pdm import "$initdir/requirements.txt"
pdm import --dev "$initdir/requirements-dev.txt"
echo "Changing to a modern version of pytest that doesn't have TOML parsing problems..."
pdm remove --dev --group dev pytest
pdm add --dev --group dev 'pytest>=7.4.0'
pdm install
pdm sync --clean

echo "3️⃣  Removing unneeded files from CDK project..."
rm -rf "$initdir"/{.git,.gitignore,.venv,requirements.txt,requirements-dev.txt,source.bat,README.md}

echo "4️⃣  Copying CDK project to current directory..."
# Remember the files to add... See https://www.shellcheck.net/wiki/SC2207
mapfile -t newfiles < <(cd "$initdir" && ls -1)
cp -Rp "$initdir"/* .
echo "Ignoring PDM files and Python caches for 'cdk watch'"
python .cdk-init/patch-cdk-json.py

echo "5️⃣  Formatting and quality fixes on code..."
# Remove commented imports that end up badly formatted
sed -i.bak -e '/# Duration,/d' -e '/# aws_sqs as sqs,/d' ./*/*.py || true
# Break long comment in app.py
sed -i.bak -e '1,$s/ region=os.getenv/\n    #     region=os.getenv/' app.py || true
# Remove backup files from sed
find ./* -name '*.bak' -print0 | xargs -0 rm -rf
# Fix problems in CDK code
pdm run ruff --fix-only .

echo "6️⃣  Adding changed files to next commit..."
git add "${newfiles[@]}" .gitignore pyproject.toml pdm.lock

echo "7️⃣ Removing files used to bootstrap a project..."
git rm -rf .cdk-init cdk-init.sh tests/test_stub.py

# Run pre-commit do do formatting, and re-add fixed files
env SKIP=dmypy pdm run pre-commit run --all || true
git add -u

# Commit
echo "8️⃣ Committing changes..."
env SKIP=dmypy git commit -F - << EOF
Ran cdk init to create project

Complete command:
cdk init $@
EOF

echo "🏆 Success! 🍰"
