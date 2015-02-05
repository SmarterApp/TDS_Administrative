#!/bin/bash
###./create_instance.sh -n cs-chris.opentestsystem.org      -e chris -r cs     -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.cs.$$
./create_instance.sh -n mna-chris.opentestsystem.org     -e chris -r mna    -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.mna.$$
./create_instance.sh -n pm-chris.opentestsystem.org      -e chris -r pm     -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.pm.$$
./create_instance.sh -n perm-chris.opentestsystem.org    -e chris -r perm   -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.perm.$$
./create_instance.sh -n odj-chris.opentestsystem.org     -e chris -r odj    -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.odj.$$
./create_instance.sh -n oam-chris.opentestsystem.org     -e chris -r oam    -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.oam.$$
./create_instance.sh -n portal-chris.opentestsystem.org  -e chris -r portal -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.portal.$$
./create_instance.sh -n auth-chris.opentestsystem.org    -e chris -r auth   -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.auth.$$
./create_instance.sh -n tsb-chris.opentestsystem.org     -e chris -r tsb    -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.tsb.$$
./create_instance.sh -n tib-chris.opentestsystem.org     -e chris -r tib    -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.tib.$$
./create_instance.sh -n tds-chris.opentestsystem.org     -e chris -r tds    -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.tds.$$
./create_instance.sh -n art-chris.opentestsystem.org     -e chris -r art    -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.art.$$

./create_instance.sh -n sftp-chris.opentestsystem.org    -e chris -r sftp    -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.sftp.$$
./create_instance.sh -n mail-chris.opentestsystem.org    -e chris -r mail    -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.mail.$$
./create_instance.sh -n cs-db-chris.opentestsystem.org   -e chris -r cs-db   -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.cs-db.$$
./create_instance.sh -n auth-db-chris.opentestsystem.org -e chris -r auth-db -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.auth.db.$$
./create_instance.sh -n art-db-chris.opentestsystem.org  -e chris -r art-db  -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.art-db.$$
./create_instance.sh -n mna-db-chris.opentestsystem.org  -e chris -r mna-db  -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.mna-db.$$
./create_instance.sh -n perm-db-chris.opentestsystem.org -e chris -r perm-db -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.perm-db.$$
./create_instance.sh -n pm-db-chris.opentestsystem.org   -e chris -r pm-db   -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.pm-db.$$
./create_instance.sh -n tds-db-chris.opentestsystem.org  -e chris -r tds-db  -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.tds-db.$$
./create_instance.sh -n tib-db-chris.opentestsystem.org  -e chris -r tib-db  -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.tib-db.$$
./create_instance.sh -n tsb-db-chris.opentestsystem.org  -e chris -r tsb-db  -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.tsb-db.$$
###./create_instance.sh -n ssh-chris.opentestsystem.org     -e chris -r ssh     -k christest -d opentestsystem.org      2>&1 | tee /tmp/out.ssh.$$

#./create_load_balancer.sh -n oam-lb-chris.opentestsystem.org   -e chris -r oam-lb -s oam-chris.opentestsystem.org    2>&1 | tee -a /tmp/out.oam-lb.$$
#./create_instance.sh -n odj-chris.opentestsystem.org           -e chris -r odj         2>&1 | tee -a /tmp/out.odj.$$

