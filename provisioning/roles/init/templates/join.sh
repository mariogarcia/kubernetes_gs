#!/usr/bin/env bash

set -e

FILE={{ master_join_script_path }}

echo "#!/usr/bin/env bash" > $FILE
echo "set -e" >> $FILE
echo `kubeadm --kubeconfig=/home/kubi/.kube/config token create --print-join-command` >> $FILE
