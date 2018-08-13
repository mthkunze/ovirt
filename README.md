# ovirt

# CentOS 7 Minimal oVirt Template

The purpose of this article is to describe the process to create a CentOS 7Minimal oVirt virtual machine for cloning to a template.

## Procedure

Update hostname
Clear machine-id; deletion is problematic next boot
Delete SSH host keys
Replace ifcfg-eth0 PREFIX with NETMASK
Edit ifcfg-eth0 to remove unnecessary values including HWADD
Delete logs
Install ovirt-guest-agent-common
Complete any additional desired configurations or installations.
(Install cloud-init; optional)
sys-unconfig (clears host specific information then poweroff)
Convert virtual machine to template
Deploy virtual machine using template

#Execute
Update the hostname to something generic (optional)

```
hostnamectl set-hostname localhost.localdomain
hostnamectl
> /etc/machine-id
Clear host SSH keys and /root/.
rm -f /etc/ssh/ssh_host_*
rrm -rf /root/.ssh/
rm -f /root/anaconda-ks.cfg
rm -f /root/.bash_history
unset HISTFILE
```

###Network Interface

Remove the HWADDR= line from /etc/sysconfig/network-scripts/ifcfg-eth0. 
Note that oVirt using cloud-init does not support PREFIX so update the ifcfg to use the equivalent NETMASK. 
If using static, I remove all items except, TYPE, BOOTPROTO, DEVICE, ONBOOT, IPADDR, NETMASK, and GATEWAY. Altenatively, use DHCP which result with:

TYPE=Ethernet
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
```
Clear logs
rm -f /var/log/boot.log
rm -f /var/log/cron
rm -f /var/log/dmesg
rm -f /var/log/grubby
rm -f /var/log/lastlog
rm -f /var/log/maillog
rm -f /var/log/messages
rm -f /var/log/secure
rm -f /var/log/spooler
rm -f /var/log/tallylog
rm -f /var/log/wpa_supplicant.log
rm -f /var/log/wtmp
rm -f /var/log/yum.log
rm -f /var/log/audit/audit.log
rm -f /var/log/ovirt-guest-agent/ovirt-guest-agent.log
rm -f /var/log/tuned/tuned.log
```
Install oVirt repository, install ovirt agent, and enable it.
yum install -y http://resources.ovirt.org/pub/yum-repo/ovirt-release42.rpm
yum install ovirt-guest-agent-common
systemctl enable ovirt-guest-agent

Cloud Init (OPTIONAL)
Install cloud-init package if desired. I experimented with cloud-init. I had mixed results for Fedora but for CentOS 7.2.1511, it worked beautifully. Remember to enable the service as shown below. Also, I suspect DHCP is a dependency but not taken the time to test.

yum install cloud-init
systemctl enable cloud-init
###Flag as unconfigured (and poweroff).

sys-unconfig
Ready to create template!

Seal Script
Peridocially, I update the templates with updates and configuration changes. I use a script to reseal the virtual machine, sealvm.sh.

```
yum install -y http://resources.ovirt.org/pub/yum-repo/ovirt-release42.rpm
yum install ovirt-guest-agent-common
systemctl enable ovirt-guest-agent

yum clean all
> /etc/machine-id
rm -f /etc/ssh/ssh_host_rm -rf /root/.ssh/
rm -f /root/anaconda-ks.cfg
rm -f /root/.bash_history
unset HISTFILE
rm -f /var/log/boot.log
rm -f /var/log/cron
rm -f /var/log/dmesg
rm -f /var/log/grubby
rm -f /var/log/lastlog
rm -f /var/log/maillog
rm -f /var/log/messages
rm -f /var/log/secure
rm -f /var/log/spooler
rm -f /var/log/tallylog
rm -f /var/log/wpa_supplicant.log
rm -f /var/log/wtmp
rm -f /var/log/yum.log
rm -f /var/log/audit/audit.log
rm -f /var/log/ovirt-guest-agent/ovirt-guest-agent.log
rm -f /var/log/tuned/tuned.log
sys-unconfig

```
###
PREP after Update

User:
```
user=myuser ; sudo virt-sysprep -a CentOS-7.qcow2 -v --run-command 'useradd $user' --ssh-inject $user:file:/home/$user/.ssh/id_rsa.pub
```
