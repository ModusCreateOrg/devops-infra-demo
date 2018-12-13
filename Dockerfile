
FROM centos:latest AS infra-demo

# setup rpm repos, install base packages and create virtual env in a single step
RUN	yum install -y https://centos7.iuscommunity.org/ius-release.rpm \
	&& yum update  -y \
	&& yum install -y \
		python36u python36u-libs python36u-devel \
		python36u-pip uwsgi-plugin-python36u uwsgi \
		gcc make glibc-devel kernel-headers \
		pcre pcre-devel pcre2 pcre2-devel \
		postgresql-devel \
	&& yum clean all \
	&& mkdir /app \
	&& python3.6 -m venv --copies --clear /app/venv

# Copy in your requirements file
ADD src/requirements.txt /app/requirements.txt

# setup python packages
RUN /app/venv/bin/pip install -U pip \
	&& /bin/sh -c "/app/venv/bin/pip install --no-cache-dir -r /app/requirements.txt"

COPY src/* /app/

RUN tar -cvzf /src/build.tar.gz /app