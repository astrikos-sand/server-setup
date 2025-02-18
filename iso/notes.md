wget https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-live-server-amd64.iso

scp -i astrikos.pem ./ubuntu.iso ubuntu@ec2-65-2-69-251.ap-south-1.compute.amazonaws.com:/home/ubuntu

sudo apt update && sudo apt install -y squashfs-tools genisoimage xorriso mkisofs

mkdir -p ~/custom-ubuntu/{mnt,extract,edit,squashfs,iso}

sudo mount -o loop /home/ubuntu/ubuntu.iso ~/custom-ubuntu/mnt

rsync -a --exclude=/casper/ubuntu-server-minimal.squashfs ~/custom-ubuntu/mnt/ ~/custom-ubuntu/extract/

sudo unsquashfs -d ~/custom-ubuntu/edit ~/custom-ubuntu/mnt/casper/ubuntu-server-minimal.squashfs

sudo mount --bind /dev/ ~/custom-ubuntu/edit/dev
sudo mount --bind /run/ ~/custom-ubuntu/edit/run


sudo chroot ~/custom-ubuntu/edit


apt update && apt install -y python3 python3-pip docker.io

mkdir -p /opt/projects

exit

sudo umount ~/custom-ubuntu/edit/dev
sudo umount ~/custom-ubuntu/edit/run


sudo mksquashfs ~/custom-ubuntu/edit ~/custom-ubuntu/extract/casper/ubuntu-server-minimal.squashfs -comp xz -b 1048576


chmod +w ~/custom-ubuntu/extract/casper/ubuntu-server-minimal.manifest
sudo chroot ~/custom-ubuntu/edit dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee ~/custom-ubuntu/extract/casper/ubuntu-server-minimal.manifest

sudo rm ~/custom-ubuntu/extract/md5sum.txt
cd ~/custom-ubuntu/extract
find . -type f -exec md5sum {} + | grep -v "isolinux/boot.cat" | sudo tee md5sum.txt

cd ~/custom-ubuntu/extract

xorriso -as mkisofs -o ~/custom-ubuntu/custom-ubuntu.iso \
    -iso-level 3 -J -l -D -r -V "CustomUbuntu" \
    -b boot/grub/i386-pc/eltorito.img -c boot.catalog \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -eltorito-alt-boot -e EFI/boot/bootx64.efi -no-emul-boot .

<!-- qemu-system-x86_64 -m 4G -cdrom ~/custom-ubuntu/custom-ubuntu.iso -accel tcg -nographic -->

sudo virt-install \
  --name ubuntu-install \
  --ram 2048 \
  --vcpus 2 \
  --disk path=/var/lib/libvirt/images/custom-ubuntu.qcow2,size=10 \
  --cdrom /var/lib/libvirt/images/custom-ubuntu.iso \
  --os-variant ubuntu22.04 \
  --network network=default \
  --graphics none \
  --console pty,target_type=serial \
  --virt-type qemu

sudo virsh list --all

sudo virsh start ubuntu-install

sudo virsh console ubuntu-install


sudo mount -o loop custom-ubuntu.iso /mnt/iso
sudo unsquashfs -f -d ubuntu-root /mnt/iso/casper/ubuntu-server-minimal.squashfs


=============================

sudo add-apt-repository ppa:cubic-wizard/release
sudo apt update

sudo apt install cubic
sudo apt install xorg


sudo apt update -y
sudo apt-get update -y

sudo apt-get install ca-certificates -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo apt install nginx -y

sudo apt install openjdk-11-jdk -y
sudo apt install maven -y

wget http://3.109.56.162/thingsboard.jar


=====


sudo mkdir -p /mnt/iso
sudo mount -o loop ~/test/testos.iso /mnt/iso


sudo mkdir -p /mnt/squashfs
sudo mount -t squashfs /mnt/iso/casper/ubuntu-server-minimal.squashfs /mnt/squashfs -o loop

sudo mkdir -p /mnt/chroot
sudo rsync -a /mnt/squashfs/ /mnt/chroot/


sudo mount --bind /dev /mnt/chroot/dev
sudo mount --bind /proc /mnt/chroot/proc
sudo mount --bind /sys /mnt/chroot/sys
sudo mount --bind /run /mnt/chroot/run

sudo chroot /mnt/chroot /bin/bash

sudo umount /mnt/chroot/dev
sudo umount /mnt/chroot/proc
sudo umount /mnt/chroot/sys
sudo umount /mnt/chroot/run
sudo umount /mnt/squashfs
sudo umount /mnt/iso

===================

