yum -y install nss-pam-ldapd  sssd pam_ldap pam_krb5 oddjob oddjob-mkhomedir krb5-workstation

setenforce 0
systemctl start dbus
systemctl restart dbus
systemctl start oddjobd
systemctl enable dbus
systemctl enable oddjobd

authconfig \
--enablelocauthorize \
--enableldap \
--disableldapauth \
--ldapserver=ldap://demoldap.hdpcloud.internal:389 \
--disableldaptls \
--ldapbasedn=dc=hdpcloud,dc=internal \
--disablerfc2307bis \
--enablemkhomedir \
--enablecache \
--enablecachecreds \
--enablekrb5 --krb5realm HDPCLOUD --krb5kdc demoldap.hdpcloud.internal --krb5adminserver demoldap.hdpcloud.internal \
--update
