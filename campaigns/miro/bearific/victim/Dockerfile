FROM debian:bookworm

RUN <<EOD
apt-get update
apt-get install -y sudo openssh-server curl ca-certificates python3-venv libssl-dev libffi-dev build-essential libpython3-dev python3-minimal authbind
mkdir /var/run/sshd
chmod 0755 /var/run/sshd
sed -i '$aPermitRootLogin yes' /etc/ssh/sshd_config
echo root:alpine | chpasswd
adduser --disabled-password cowrie --gecos ""
EOD

USER cowrie
RUN <<EOD
cd
# Cowrie v2.6.1 was the latest release when this challenge was created.
curl -fsSL https://codeload.github.com/cowrie/cowrie/tar.gz/refs/tags/v2.6.1 -o cowrie.tar.gz
echo "3e6c24791f2ba309d126678445369b2dc4ccb6f97c2ccb188c534c4d3704abba  cowrie.tar.gz" | sha256sum -c -
tar -xzf cowrie.tar.gz
mv cowrie-2.6.1 cowrie
rm cowrie.tar.gz
cd cowrie
python3 -m venv cowrie-env
. cowrie-env/bin/activate
python3 -m pip install --upgrade -r requirements.txt
EOD

USER root
CMD /usr/sbin/sshd -D
