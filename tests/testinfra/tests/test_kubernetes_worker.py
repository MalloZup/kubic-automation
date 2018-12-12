# Copyright 2017 SUSE LINUX GmbH, Nuernberg, Germany.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import pytest

from .utils import TestUtils

@pytest.mark.worker
class TestKubernetesWorker(object):
    @pytest.mark.bootstrapped
    @pytest.mark.parametrize("service", [
        "kubelet",
        "kube-proxy"
    ])
    def test_services_running(self, host, service):
        host_service = host.service(service)
        assert host_service.is_running

    @pytest.mark.bootstrapped
    @pytest.mark.parametrize("service", [
        "container-feeder",
    ])
    def test_service_non_registry(self, host, service):
        """Test service is only running when not using registry."""
        registry_conf = TestUtils.load_registry_configuration(host)
        if not registry_conf['use_registry']:
            host_service = host.service(service)
            assert host_service.is_running

    @pytest.mark.bootstrapped
    @pytest.mark.skipif(
        TestUtils.feature_matches('cri', {'implementation': 'docker'}),
        reason="CRI is not Docker")
    def test_docker_service_running(self, host, service):
        assert host.service('docker').is_running

    @pytest.mark.bootstrapped
    @pytest.mark.parametrize("service", [
        "kubelet",
        "kube-proxy"
    ])
    def test_services_enabled(self, host, service):
        host_service = host.service(service)
        assert host_service.is_enabled

    @pytest.mark.bootstrapped
    @pytest.mark.skipif(
        TestUtils.feature_matches('cri', {'implementation': 'docker'}),
        reason="CRI is not Docker")
    def test_docker_service_enabled(self, host, service):
        assert host.service('docker').is_enabled

    @pytest.mark.bootstrapped
    @pytest.mark.parametrize("service", [
        "kube-apiserver",
        "kube-controller-manager",
        "kube-scheduler",
    ])
    def test_services_stopped(self, host, service):
        host_service = host.service(service)
        assert host_service.is_running == False

    @pytest.mark.bootstrapped
    @pytest.mark.parametrize("service", [
        "kube-apiserver",
        "kube-controller-manager",
        "kube-scheduler",
    ])
    def test_services_disabled(self, host, service):
        host_service = host.service(service)
        assert host_service.is_enabled == False

    @pytest.mark.bootstrapped
    def test_salt_role(self, host):
        assert 'kube-minion' in host.salt("grains.get", "roles")

    @pytest.mark.bootstrapped
    def test_salt_id(self, host):
        machine_id = host.file('/etc/machine-id').content_string.rstrip()
        assert machine_id in host.salt("grains.get", "id")

    def _test_etcd_aliveness(self, host, hostname):
        if 'etcd' in host.salt("grains.get", "roles"):
            machine_id = host.file('/etc/machine-id').content_string.rstrip()
            cmd = "etcdctl --ca-file /etc/pki/trust/anchors/SUSE_CaaSP_CA.crt "\
                  "--key-file /etc/pki/minion.key "\
                  "--cert-file /etc/pki/minion.crt "\
                  "--endpoints='https://%s:2379' "\
                  "cluster-health" % hostname

            # TODO: Switch back to run_expect once we remove compatibility for
            #       our generated hostnames.
            health = host.run(cmd)

            return "cluster is healthy" in health.stdout
        else:
            return True

    @pytest.mark.bootstrapped
    def test_etcd_aliveness(self, host):
        # TODO: Remove the machine_id compatibility once we remove our
        #       generated hostnames.
        machine_id = host.file('/etc/machine-id').content_string.rstrip()
        hostname = host.file('/etc/hostname').content_string.rstrip()

        result = False
        if self._test_etcd_aliveness(host, "%s.infra.caasp.local" % machine_id):
            result = True

        if self._test_etcd_aliveness(host, hostname):
            result = True

        assert result is True
