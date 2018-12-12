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


@pytest.mark.common
class TestCommon(object):
    @pytest.mark.removed
    @pytest.mark.unused
    def test_dummy_test(self, host):
        # A dummy test that does nothing, but lets CI pass without yet having any
        # removed/unused tests as a testinfra.xml will  be generated with at least
        # one test. Remove once we have at least 1 test for each role+status
        # combination.
        pass

    @pytest.mark.bootstrapped
    @pytest.mark.parametrize("service", [
        "salt-minion"
    ])
    def test_services_running(self, host, service):
        host_service = host.service(service)
        assert host_service.is_running

    @pytest.mark.bootstrapped
    @pytest.mark.parametrize("service", [
        "salt-minion"
    ])
    def test_services_enabled(self, host, service):
        host_service = host.service(service)
        assert host_service.is_enabled

    @pytest.mark.bootstrapped
    def test_bootstrap_grain_bootstrapped(self, host):
        assert host.salt("grains.get", "bootstrap_complete")
