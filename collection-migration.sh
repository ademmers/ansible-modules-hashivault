#!/bin/bash

mv ansible/modules plugins/
mv ansible/plugins/* plugins/
mv ansible/__init__.py plugins/modules/
mv ansible/module_utils plugins/
mv plugins/modules/hashivault/* plugins/modules/
rm -rf plugins/modules/hashivault/
rm -rf plugins/module_utils/__init__.py
mv functional tests
rm -rf meta/main.yml
rm -rf ansible/
find ./ -name '*.py' | xargs -I{} grep -l 'from ansible.module_utils' {} | xargs -I{} sed -i 's/from ansible.module_utils/from ansible_collections.terryhowe.hashivault.plugins/' {}
sed -i 's!ansible/module_utils!plugins/module_utils!' setup.py
sed -i 's!ansible/plugins!plugins!' setup.py
sed -i 's!ansible/modules/hashivault!plugins/modules!' setup.py
sed -i 's/hashivault_unseal:/terryhowe.hashivault.hashivault_unseal:/' tests/test_init.yml
sed -i 's'!/functional/!/tests/!' tox.ini
find ./ -name '*.yml' -or -name '*.py' | xargs -I{} grep -l "lookup('hashivault'" {} | xargs -I{} sed -i "s/lookup('hashivault'/lookup('terryhowe.hashivault.hashivault'/" {}
find ./ -name '*.yml' -or -name '*.py' | xargs -I{} grep -l "lookup('vault'" {} | xargs -I{} sed -i "s/lookup('vault'/lookup('terryhowe.hashivault.hashivault'/" {}

git add plugins/ tests/ setup.py module_utils meta lookup_plugins library functional example/test_remote_host.yml ansible action_plugins galaxy.yml
git commit -m "ansible-collection migration"

git format-patch -1 91d9746723a645bca8bfc9af8202de8b406bb84a -- .travis.yml .gitignore tests/ansible.cfg tests/test_write.yml tests/userpassenv.sh
git format-patch -1 d51589753ce30de6d06822c53e4f0c285d44e26b -- galaxy.yml
git am 0001-Replaced-metadata-with-galaxy-manifest.patch
git reset --soft HEAD~1
git commit --amend --no-edit
git am 0001-ansible-collection-update-tox-tests-etc.patch
git reset --soft HEAD~1
git commit --amend --no-edit
