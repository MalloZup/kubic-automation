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
import os

import pytest
import json

from .utils import TestUtils

@pytest.mark.master
class TestKubernetesMaster(object):
    @pytest.mark.bootstrapped
    @pytest.mark.parametrize("service", [
        "kube-apiserver",
        "kube-controller-manager",
        "kube-scheduler",
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
        "kube-apiserver",
        "kube-controller-manager",
        "kube-scheduler",
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
    def test_salt_role(self, host):
        assert 'kube-master' in host.salt("grains.get", "roles")

    @pytest.mark.bootstrapped
    def test_kubernetes_cluster(self, host):
        host.run(
            "kubectl cluster-info dump --output-directory=/tmp/cluster_info"
        )

        nodes = json.loads(
            host.file("/tmp/cluster_info/nodes.json").content_string
        )

        env = TestUtils.environment()
        assert (len(nodes["Items"]) == sum(1 for i in env["minions"] if i["role"] != "admin" and i["status"] == "bootstrapped"))

        # Check all nodes are marked as "Ready" in k8s
        for node in nodes["Items"]:
            for item in node["Status"]["Conditions"]:
                if item["Type"] is "Ready":
                    assert bool(item["Status"])

    @pytest.mark.bootstrapped
    def test_salt_id(self, host):
        machine_id = host.file('/etc/machine-id').content_string.rstrip()
        assert machine_id in host.salt("grains.get", "id")
