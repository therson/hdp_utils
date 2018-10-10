for r in `cat host.all`; do
	echo "addprinc -randkey host/${r}.hdpcloud.internal@SMMDEMO"
	echo "xst -norandkey -kt $r.keytab host/${r}.hdpcloud.internal@SMMDEMO"
done;

addprinc -randkey host/master0.hdpcloud.internal@SMMDEMO
xst -norandkey -kt master0.keytab host/master0.hdpcloud.internal@SMMDEMO

for r in `cat host.all`; do
	scp -oStrictHostKeyChecking=no $r.keytab $r.hdpcloud.internal:/etc/krb5.keytab 
done;


for r in `cat host.all`; do
	ssh -oStrictHostKeyChecking=no $r echo "hello"
done;