# Kubernetes upstream conformance e2e tests for CaaSP cluster

This is automation for Kubernetes upstream end-to-end tests for CaaSP cluster

## Overview

Upstream conformance Kubernetes tests.

## Usage

### Requirements

In order to run the Kubernetes conformance e2e tests, the CaaSP cluster has to be installed first. After installation `kubeconfig` has to be to extracted on machine where tests will be started.

#### Steps to run Kubernetes end-to-end tests

1. Download `kubeconfig`, on the machine where would you like to run k8s end-to-end tests.

2. Clone automation repository on the test machine
```
git clone https://github.com/kubic-project/automation
```

3. Go into run directory
```
cd automation/k8s-e2e-tests
```

4. Run tests with the following command
```
./e2e-tests -k <path_to_kubeconfig>
```

5. Wait until tests end, results will be stored in the provided path

Additionally, you can also provide an `--artifacts` folder where all e2e artifacts will be stored.
Refer to the help command `./e2e-tests -h` for more information.

#### Images used by the Kubernetes e2e tests

During running end-to-end tests, Kubernetes try to pull images from Google's registry.

#### Main options

You can either provide your own `kubeconfig` or point the script to the Kubernetes API server URL (both methods are mutually exclusive)

* `-k|--kubeconfig <FILE>`
    When "kubeconfig" is provided without certificates, they should be
    embedded.
