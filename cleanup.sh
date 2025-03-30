#!/bin/bash
# Cleanup script to remove old configuration directories

# Remove old core modules
git rm -rf hosts/common/core

# Remove old optional modules
git rm -rf hosts/common/optional

# Remove old user modules
git rm -rf hosts/common/users

# Commit changes
git commit -m "refactor: remove old configuration directories after migration to new structure"
