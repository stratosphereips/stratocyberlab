FROM debian:bookworm

RUN <<EOD
apt-get update
apt-get install -y sudo openssh-server git python3-venv libssl-dev libffi-dev build-essential libpython3-dev python3-minimal authbind
mkdir /var/run/sshd
chmod 0755 /var/run/sshd
sed -i '$aPermitRootLogin yes' /etc/ssh/sshd_config
echo root:alpine | chpasswd
adduser --disabled-password cowrie --gecos ""
EOD

USER cowrie
RUN <<EOD
cd
# install cowrie - steps as per https://docs.cowrie.org/en/latest/INSTALL.html
git clone https://github.com/cowrie/cowrie
cd cowrie
python3 -m venv cowrie-env
. cowrie-env/bin/activate
python3 -m pip install --upgrade -r requirements.txt
EOD

USER root
CMD /usr/sbin/sshd -D
