### Example to illustrate how a VSI can use Block Storage as data volume to store mongo db data.   

The intent of this article is to walk you through the process that are involved in setting up a virtual server instance (VSI) with block storage as data volume to store mongo db data in the IBM Cloud VPC. Since, the mongo db data is stored in Block Storage volume, any Virtual Server Instance can mount the data from Block storage, use it as a secondary volume and reuse the mongo db data.   

After the setup, you can configure private dns, mongo db in the server VSI and connect to mongo db from a client VSI that is running nodejs application. The client and server will communicate using Private DNS (p-DNS).

The example below illustrates how a Virtual Server Instance in IBM Cloud VPC can use Block Storage as data volume to store mongo db data.  

![Demo Overview](images/Demo-Overview.png)

The reader will get to know the steps to attach a Block Storage to a VSI and configure MongoDB:

- Create Block Storage volume. 
- Partition the volume, format the volume, and then mount it as a file system in Server VSI. 
- Install Docker and Mongodb as docker container.
- Run Mongodb container and use the mounted secondary block volume. 
- Create a database in mongo db.
- Connect to Mongodb using mongo client and test whether setup works.    

> Prerequisite:

- IBM Cloud account.   
- Follow the steps from [Example to illustrate how a nodejs application can access Mongo DB using Private DNS](https://github.com/IBM-Cloud/vnf-samples/blob/master/pdns-mongo-nodejs/README.md) and create a Server VSI, Client VSI and private dns (testb.testpdns.com)

**Apply Terraform**   

1. Run the command to initialize ibm terraform provider:  
> terraform init

2. Run the command to apply terraform:  
> terraform apply

3. It will create 3 VSI: 1 client VSI and 2 Server VSIs. One of the server VSI is attached to a block storage volume(resource **ibm_is_volume** "volume" is attached to the resource **ibm_is_instance** "test_schematics_demo_vsi_server_1"") with size 20 GB as shown below:  

![Block Storage Volume](images/Block-Storage-VSI.png)

4. Next, lets follow this procedure to use block storage volume on ubuntu system ![Using your block storage data volume ](https://cloud.ibm.com/docs/vpc?topic=vpc-start-using-your-block-storage-data-volume). 

a) Login to the Server VSI using floating ip address. 

ssh root@floating ip of server vsi 1

b) Run the command **df -Th** :  

Here, you can see that the data volume 20GB is not shown.    

```
root@server-1:~# df -Th
Filesystem     Type      Size  Used Avail Use% Mounted on
udev           devtmpfs  3.7G     0  3.7G   0% /dev
tmpfs          tmpfs     743M  660K  742M   1% /run
/dev/vda2      ext4       99G  1.5G   93G   2% /
tmpfs          tmpfs     3.7G     0  3.7G   0% /dev/shm
tmpfs          tmpfs     5.0M     0  5.0M   0% /run/lock
tmpfs          tmpfs     3.7G     0  3.7G   0% /sys/fs/cgroup
/dev/vda1      ext3      240M   73M  155M  33% /boot
tmpfs          tmpfs     743M     0  743M   0% /run/user/0
```
c) Run the command **fdisk -l** :  

Here, you can see that the data volume 20GB is shown under Disk /dev/vdd but it is not mounted to this server.    
```
root@server-1:~# fdisk -l
Disk /dev/vda: 100 GiB, 107372544000 bytes, 209712000 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x9493729e

Device     Boot  Start       End   Sectors  Size Id Type
/dev/vda1  *      2048    526335    524288  256M 83 Linux
/dev/vda2       526336 209711966 209185631 99.8G 83 Linux


Disk /dev/vdb: 370 KiB, 378880 bytes, 740 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/vdc: 44 KiB, 45056 bytes, 88 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/vdd: 20 GiB, 21474836480 bytes, 41943040 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
``` 
d) Run the command to make file system in **/dev/vdd**. This is a one time task. This is needed only for new block storage volumes.  

```
root@server-1:~# mkfs.ext4 /dev/vdd
mke2fs 1.44.1 (24-Mar-2018)
Creating filesystem with 5242880 4k blocks and 1310720 inodes
Filesystem UUID: 72d938e3-a56d-4e50-a62a-d953b4d2bda7
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000

Allocating group tables: done                              
Writing inode tables: done                              
Creating journal (32768 blocks): done   
Writing superblocks and filesystem accounting information:          
done
```
e) Create a secondary directory **/mnt/secondary**, and mount this directory to block storage volume. Grant permission 0775 to the secondary volume. Run the below commands:    

```
root@server-1:~# mkdir /mnt/secondary
root@server-1:~# chmod 0775 /mnt/secondary
```

f) Mount this directory to block storage volume.  Run the command:  

```
mount /dev/vdd /mnt/secondary
```

g) Find the UUID of the partition /dev/vdd.  Run the below command:  

```
root@server-1:~# blkid /dev/vdd -sUUID -ovalue
72d938e3-a56d-4e50-a62a-d953b4d2bda7
```

Note down the UUID of the partition /dev/vdd.  

h) Edit the file "/etc/fstab". Add this line. 
```
/dev/disk/by-uuid/72d938e3-a56d-4e50-a62a-d953b4d2bda7 /mnt/secondary ext4 defaults 0 0 
```
g) Run the command : mount. It should not display any error. 

```
root@server-1:~# mount
...
/dev/vdd on /mnt/secondary type ext4 (rw,relatime,data=ordered)

```
It should display /dev/vdd at the last line as file system directory mounted to /mnt/secondary directory. The block storage volume is using partition /dev/vdd in server VSI and is mounted to  /mnt/secondary directory.  





**References:**

Installing Docker in ubuntu
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04

How to Deploy and Manage MongoDB with Docker
https://phoenixnap.com/kb/docker-mongodb

Using your block storage data volume (CLI)
https://cloud.ibm.com/docs/vpc?topic=vpc-start-using-your-block-storage-data-volume

Steps to format and mount block storage volume 
https://github.com/hkantare/terraform-vpc-db/blob/master/playbooks/mount.yml

https://www.thachmai.info/2015/04/30/running-mongodb-container/















