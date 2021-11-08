git add .
git commit -m "update just before batch run"
git push
ssh -i /Users/keletsomakofane/Documents/_security/rce_key kem073@rce.hmdc.harvard.edu
cd ~/shared_space/thesis_kem073/_gitrepos/constellations
git fetch --all
git reset --hard origin/main

cd ~/shared_space/thesis_kem073/_gitrepos/ahdss_physfunction/_create_networks

condor_submit batch.submit
logout

