MANUAL = prometheus2 \
alertmanager \
thanos \
elasticsearch_exporter \
jmx_exporter \
rabbitmq_exporter \
ping_exporter \
couchbase_exporter \
mtail \

AUTO_GENERATED = node_exporter \
blackbox_exporter \
snmp_exporter \
pushgateway \
mysqld_exporter \
postgres_exporter \
redis_exporter \
haproxy_exporter \
kafka_exporter \
nginx_exporter \
bind_exporter \
json_exporter \
keepalived_exporter \
jolokia_exporter \
frr_exporter \
domain_exporter \
mongodb_exporter \
graphite_exporter \
statsd_exporter \
collectd_exporter \
memcached_exporter \
consul_exporter \
smokeping_prober \
iperf3_exporter \
apache_exporter \
influxdb_exporter \
exporter_exporter \
junos_exporter \
openstack_exporter \
process_exporter \
ssl_exporter \
sachet \
jiralert \
ebpf_exporter \
karma \
ctdb_exporter

.PHONY: $(MANUAL) $(AUTO_GENERATED)

INTERACTIVE:=$(shell [ -t 0 ] && echo 1)
ifdef INTERACTIVE
	DOCKER_FLAGS = -it --rm
else
	DOCKER_FLAGS = --rm
endif

all: auto manual

manual: $(MANUAL)
auto: $(AUTO_GENERATED)

manual8: $(addprefix build8-,$(MANUAL))
manual7: $(addprefix build7-,$(MANUAL))

$(addprefix build8-,$(MANUAL)):
	$(eval PACKAGE=$(subst build8-,,$@))
	[ -d ${PWD}/_dist8 ] || mkdir ${PWD}/_dist8 
	[ -d ${PWD}/_cache_dnf ] || mkdir ${PWD}/_cache_dnf 
	docker run ${DOCKER_FLAGS} \
		-v ${PWD}/${PACKAGE}:/rpmbuild/SOURCES \
		-v ${PWD}/_dist8:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/_dist8:/rpmbuild/RPMS/noarch \
		-v ${PWD}/_cache_dnf:/var/cache/dnf \
		ghcr.io/lest/centos-rpm-builder:8 \
		build-spec SOURCES/${PACKAGE}.spec
	# Test the install
	[ -d ${PWD}/_dist8 ] || mkdir ${PWD}/_dist8      
	[ -d ${PWD}/_cache_dnf ] || mkdir ${PWD}/_cache_dnf
	docker run --privileged ${DOCKER_FLAGS} \
		-v ${PWD}/_dist8:/var/tmp/ \
		-v ${PWD}/_cache_dnf:/var/cache/dnf \
		ghcr.io/lest/centos-rpm-builder:8 \
		/bin/bash -c '/usr/bin/dnf install --verbose -y /var/tmp/${PACKAGE}*.rpm'

$(addprefix build7-,$(MANUAL)):
	$(eval PACKAGE=$(subst build7-,,$@))
	[ -d ${PWD}/_dist7 ] || mkdir ${PWD}/_dist7      
	[ -d ${PWD}/_cache_yum ] || mkdir ${PWD}/_cache_yum
	docker run ${DOCKER_FLAGS} \
		-v ${PWD}/${PACKAGE}:/rpmbuild/SOURCES \
		-v ${PWD}/_dist7:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/_dist7:/rpmbuild/RPMS/noarch \
		-v ${PWD}/_cache_yum:/var/cache/yum \
		ghcr.io/lest/centos-rpm-builder:7 \
		build-spec SOURCES/${PACKAGE}.spec
	# Test the install
	[ -d ${PWD}/_dist7 ] || mkdir ${PWD}/_dist7      
	[ -d ${PWD}/_cache_yum ] || mkdir ${PWD}/_cache_yum
	docker run --privileged ${DOCKER_FLAGS} \
		-v ${PWD}/_dist7:/var/tmp/ \
		-v ${PWD}/_cache_yum:/var/cache/yum \
		ghcr.io/lest/centos-rpm-builder:7 \
		/bin/bash -c '/usr/bin/yum install --verbose -y /var/tmp/${PACKAGE}*.rpm'


auto8: $(addprefix build8-,$(AUTO_GENERATED))
auto7: $(addprefix build7-,$(AUTO_GENERATED))

$(addprefix build8-,$(AUTO_GENERATED)):
	$(eval PACKAGE=$(subst build8-,,$@))

	python3 ./generate.py --templates ${PACKAGE}
	[ -d ${PWD}/_dist8 ] || mkdir ${PWD}/_dist8      
	[ -d ${PWD}/_cache_dnf ] || mkdir ${PWD}/_cache_dnf
	docker run ${DOCKER_FLAGS} \
		-v ${PWD}/${PACKAGE}:/rpmbuild/SOURCES \
		-v ${PWD}/_dist8:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/_dist8:/rpmbuild/RPMS/noarch \
		-v ${PWD}/_cache_dnf:/var/cache/dnf \
		ghcr.io/lest/centos-rpm-builder:8 \
		build-spec SOURCES/autogen_${PACKAGE}.spec
	# Test the install
	[ -d ${PWD}/_dist8 ] || mkdir ${PWD}/_dist8      
	[ -d ${PWD}/_cache_dnf ] || mkdir ${PWD}/_cache_dnf
	docker run --privileged ${DOCKER_FLAGS} \
		-v ${PWD}/_dist8:/var/tmp/ \
		-v ${PWD}/_cache_dnf:/var/cache/dnf \
		ghcr.io/lest/centos-rpm-builder:8 \
		/bin/bash -c '/usr/bin/dnf install --verbose -y /var/tmp/${PACKAGE}*.rpm'

sign8:
	docker run --rm \
		-v ${PWD}/_dist8:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/bin:/rpmbuild/bin \
		-v ${PWD}/RPM-GPG-KEY-prometheus-rpm:/rpmbuild/RPM-GPG-KEY-prometheus-rpm \
		-v ${PWD}/secret.asc:/rpmbuild/secret.asc \
		-v ${PWD}/.passphrase:/rpmbuild/.passphrase \
		ghcr.io/lest/centos-rpm-builder:8 \
		bin/sign

$(addprefix build7-,$(AUTO_GENERATED)):
	$(eval PACKAGE=$(subst build7-,,$@))

	python3 ./generate.py --templates ${PACKAGE}
	[ -d ${PWD}/_dist7 ] || mkdir ${PWD}/_dist7
	[ -d ${PWD}/_cache_yum ] || mkdir ${PWD}/_cache_yum
	docker run ${DOCKER_FLAGS} \
		-v ${PWD}/${PACKAGE}:/rpmbuild/SOURCES \
		-v ${PWD}/_dist7:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/_dist7:/rpmbuild/RPMS/noarch \
		-v ${PWD}/_cache_yum:/var/cache/yum \
		ghcr.io/lest/centos-rpm-builder:7 \
		build-spec SOURCES/autogen_${PACKAGE}.spec
	# Test the install
	[ -d ${PWD}/_dist7 ] || mkdir ${PWD}/_dist7
	[ -d ${PWD}/_cache_yum ] || mkdir ${PWD}/_cache_yum
	docker run --privileged ${DOCKER_FLAGS} \
		-v ${PWD}/_dist7:/var/tmp/ \
		-v ${PWD}/_cache_yum:/var/cache/yum \
		ghcr.io/lest/centos-rpm-builder:7 \
		/bin/bash -c '/usr/bin/yum install --verbose -y /var/tmp/${PACKAGE}*.rpm'

sign7:
	docker run --rm \
		-v ${PWD}/_dist7:/rpmbuild/RPMS/x86_64 \
		-v ${PWD}/bin:/rpmbuild/bin \
		-v ${PWD}/RPM-GPG-KEY-prometheus-rpm:/rpmbuild/RPM-GPG-KEY-prometheus-rpm \
		-v ${PWD}/secret.asc:/rpmbuild/secret.asc \
		-v ${PWD}/.passphrase:/rpmbuild/.passphrase \
		ghcr.io/lest/centos-rpm-builder:7 \
		bin/sign

$(foreach \
	PACKAGE,$(MANUAL),$(eval \
		${PACKAGE}: \
			$(addprefix build8-,${PACKAGE}) \
			$(addprefix build7-,${PACKAGE}) \
	) \
)

$(foreach \
	PACKAGE,$(AUTO_GENERATED),$(eval \
		${PACKAGE}: \
			$(addprefix build8-,${PACKAGE}) \
			$(addprefix build7-,${PACKAGE}) \
	) \
)

sign: sign8 sign7

publish8: sign8
	package_cloud push --skip-errors prometheus-rpm/release/el/8 _dist8/*.rpm

publish7: sign7
	package_cloud push --skip-errors prometheus-rpm/release/el/7 _dist7/*.rpm

publish: publish8 publish7

clean:
	rm -rf _cache_dnf _cache_yum _dist*
	rm -f **/*.tar.gz
	rm -f **/*.jar
	rm -f **/autogen_*{default,init,unit,spec}
