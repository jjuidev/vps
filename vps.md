# Khi có 1 VPS (Virtual Private Server) ta sẽ được cấp 1 IP và 1 password

- Ví dụ:
  - IP: 123.456.789.012
  - Password: 123456

# SSH là gì?

- SSH là giao thức bảo mật để truy cập vào VPS.
- ssh có port mặc định là 22.

# Check system OS

cat /etc/os-release

# Login vào VPS bằng username và password

- ssh root@123.456.789.012: Lệnh này yêu cầu login với user root và sẽ yêu cầu nhập password cho user root.
  - root: là tên người dùng
  - 123.456.789.012: là IP của VPS

# Settings zsh và plugins cho VPS (optional)

```bash
# Cài đặt zsh
sudo apt install zsh

# Liệt kê các shell có trong hệ thống
cat /etc/shells

# Kiểm tra shell hiện tại
echo $SHELL

# Chuyển sang zsh
chsh -s $(which zsh)

# Copy file zshrc mẫu nếu chưa có
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# Source file zshrc để áp dụng cấu hình
source ~/.zshrc

# Cài đặt thư viện oh-my-zsh, plugins auto suggestion, syntax highlighting và thêm vào .zshrc
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Thêm vào .zshrc
vi ~/.zshrc

# Thêm vào .zshrc
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

```

# Login vào VPS bằng SSH key (thuận tiện và an toàn hơn - recommended)

## Một số lệnh và thao tác với user

### User

```bash
# Xem thông tin user hiện tại
whoami

# Xem danh sách các group có trong hệ thống
cat /etc/group
cat /etc/group | grep <groupname>

# Xem danh sách các user có trong hệ thống
cat /etc/passwd
cat /etc/passwd | grep <username>

# Xem danh sách group của user hiện tại
groups
groups <username>

# Show danh sách user thật hiện có
awk -F: '$3 >= 1000 {print $1}' /etc/passwd

# Tạo mới 1 user
adduser <username>

# Xóa 1 user
userdel <username>

# Xoá 1 user, xoá luôn folder của user đó
userdel -r <username>

# Đổi password cho user, đổi cho chính user hiện tại
passwd

# Đổi password cho user khác, cần qunyền sudo
sudo passwd <user>

# Thêm 1 user vào 1 group
usermod -aG <groupname> <username>
# Ví dụ:
usermod -aG sudo tandm

# Do trong /etc/sudoers
# Có dòng lệnh %sudo   ALL=(ALL:ALL) ALL - Tức nghĩa là tất cả user nào có trong group sudo đều có ALL quyền nên có thể dùng lệnh usermod -aG sudo tandm
# Trong các os system khác, có thể có dòng %whell   ALL=(ALL:ALL) ALL thì khi đó sẽ dùng usermod -aG whell tandm
# Đó là cách 1 (khuyến cáo)
# Nên mình cũng có thể sử dụng cách 2 là chỉnh sửa file /etc/sudoers -> jjuidev    ALL=(ALL:ALL) ALL
# Nhưng theo mặc định file /etc/sudoers chỉ có quyền mặc định là read cho user và group root
# Bạn phải login vào bằng user root và thay đổi quyền của file, giả sử sudo chmod u+w /etc/sudoers
# Và tiền hành ghi vào file /etc/sudoers -> jjuidev    ALL=(ALL:ALL) ALL
# Sau khi ghi xong, nên cập nhật lại quyền cho file /etc/sudoers, giả sử sudo chmod u-w /etc/sudoers

# Xóa 1 user khỏi 1 group
gpasswd -d <username> <groupname>
# Ví dụ:
gpasswd -d tandm sudo

# Switch user
su - <username>
# Ví dụ:
su - tandm

# Xem user sử dụng bash hay zsh
echo $SHELL

```

### sudo, chmod, chown, chgrp

```bash
# Xem quyền của file
ls
ls -l
ls -la
ll

ls -l <filename>
ls -la <filename>
ll <filename>

# Ký tự đầu tiên bắt đầu bằng dấu - là file, bắt đầu bằng dấu d là folder, bắt đầu bằng dấu l là symbol link (alias)
# 9 ký tự tiếp theo là quyền của file bao gồm 3 nhóm 3 ký tự
# Nhóm thứ nhất là quyền của user - u
# Nhóm thứ hai là quyền của group - g
# Nhóm thứ ba là quyền của other - o

# Trong đó:
# r: read (nếu tính theo hệ bát phân thì r = 4)
# w: write (nếu tính theo hệ bát phân thì w = 2)
# x: execute (nếu tính theo hệ bát phân thì x = 1)
# -: không có quyền (nếu tính theo hệ bát phân thì - = 0)

# Dùng ký tự r, w, x, a
# Thêm quyền cho user, group, other
chmod u+x <filename>
chmod u+x,g+x,o+x <filename>
chmod a+x <filename>

# Bỏ quyền của user, group, other
chmod u-x <filename>
chmod u-x,g-x,o-x <filename>
chmod a-x <filename>

# Gán quyền cho user, group, other
chmod u=rwx,g=rwx,o=rwx <filename>
chmod a=rwx <filename>

# Gán quyền cho user, group, other
chmod u=rwx,g=rwx,o=rwx <filename>

# Gán quyền cho user, group, other
chmod u=rwx,g=rwx,o=rwx <filename>
chmod a=rwx <filename>

# Dùng hệ bát phân
# Thêm quyền cho user, group, other
chmod <permission> <filename>
# Ví dụ: chmod 755 <filename>

# Bỏ quyền của user, group, other
chmod u-x,g-x,o-x <filename>
# Ví dụ: chmod 000 <filename>
chmod a=000 <filename>

# Thay đổi quyền của folder
chmod -R <permission> <foldername>
# Ví dụ: chmod -R 000 <foldername>
chmod -R a=000 <foldername>
```

## Settings SSH key

- Tạo SSH key ở máy local

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
# hoặc
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Chỉ định folder lưu file private key
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_ed25519
# Trong đó, chuẩn ed25519 là mặc định và tốt hơn về mặt bảo mật so với rsa, khuyến khích sử dụng.

# Copy file public key sang VPS
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@123.456.789.012
# Ví dụ: gõ lệnh này ở máy local và nhập password của user trên VPS
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@123.456.789.012

# sshd_config
# Theo mặc định, config trong file /etc/ssh/sshd_config sẽ default 2 option sau bị comment, điều này khiến lệnh ssh-copy-id không thể copy lên VPS cho user root được
# Cần phải login trực tiếp bằng tk/mk tại máy VPS (điều này không thể với VPS thật), hoặc login bằng user khác nhưng có quyền root và tiến hành update file /etc/ssh/sshd_config
# #PermitRootLogin prohibit-password -> PermitRootLogin yes
# #PasswordAuthentication yes -> PasswordAuthentication yes
# Sau đó tiến hành thực hiện lệnh ssh-copy-id cho user root và nhập mật khẩu của user root
# Lệnh ssh-copy-id sẽ copy ssh key vào /root/.ssh/authorized_keys nếu là user root, vào ~/.ssh/authorized_keys nếu là user khác. Nên bạn có thể vào 2 path này để kiểm tra, nhưng nói chung nếu bạn ssh được thì tất nhiên trong path đó phải có
# Sau khi config được ssh cho use root thì nên trả lại config không thể ssh vào VPS bằng tk/mk để bảo vệ VPS
# PermitRootLogin yes -> #PermitRootLogin prohibit-password
# PasswordAuthentication yes -> #PasswordAuthentication yes
# Dùng thêm lệnh service ssh restart

# Interval 300s VPS sẽ gửi client 1 gói tin kiểm tra, nếu client không phản hồi, phiên SSH bị ngắt ngay lập tức.
vi /etc/ssh/sshd_config
ClientAliveInterval 180
ClientAliveCountMax 0

vi /etc/zsh/zshenv
export TMOUT=300

# Config ssh key ở máy local
vi ~/.ssh/config

# jjuidev-vps server (Parallels Desktop)
Host your_host_vps # Ví dụ jjuidev-vps, khi đó ssh ở terminal local sẽ có dạng: ssh jjuidev-vps
	HostName 10.211.55.8 # IP của máy host
	User jjuidev # User cần login của máy host
	IdentityFile ~/.ssh/id_ed25519_jjuidev_vps # Đường dẫn tới ssh key của máy local
	IdentitiesOnly yes # SSH chỉ dùng đúng key được khai báo trong IdentityFile
	Port 22 # Port ssh của máy host, default là 22
```
