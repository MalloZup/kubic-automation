# Velum bootstrap

This project hosts the former [end-to-end tests](https://github.com/kubic-project/e2e-tests) for
the CaaS platform. They are meant to be run against a CaaSP cluster.

This can be either a production environment installed from images, or a caasp-kvm build cluster.

## CLI Syntax

    Usage:

      * Setup your workstation

        --setup                          Install Dependencies

      * Building a cluster

        -c|--configure                   Configure Velum
                        --choose-crio    Choose cri-o when configuring Velum
        -b|--bootstrap                   Bootstrap (implies Download Kubeconfig)
        -k|--download-kubeconfig         Download Kubeconfig
        --enable-tiller                  Enable Helm Tiller

      * Updating a cluster

        -a|--update-admin                Update admin node
        -m|--update-minions              Update masters and workers

      * General Options

        -e|--environment                 Set path to environment.json

      * Examples:

      Bootstrap a cluster

      ./velum-interactions --configure --bootstrap

      Update a cluster

      ./velum-interactions --update-admin --update-minions

## Requirements

You can install the necessary dependancy packages with:

    $ sudo zypper in ruby2.1-rubygem-bundler ruby2.1-devel phantomjs libxml2-devel libxslt-devel

## Running the tool

First you need to have a running CaaSP cluster with `velum` ready to register the first user, and at
least 2 minions up and running. If you have already registered with Velum, this tool will not correctly
bootstrap the cluster/

This tool requires an "environment.json" file is supplied to it, providing details of where to find Velum
and details on the cluster to be bootstrapped. caasp-kvm, caasp-openstack-heat, and the legacy terraform
repo will each generate this file for you as you build your cluster.

    VERBOSE=true ENVIRONMENT=/home/$USER/caasp/automation/caasp-kvm/environment.json bundle exec rspec spec/**/*

## Tools Used

This project is using [Rspec](http://rspec.info/) and [Capybara](http://www.rubydoc.info/gems/capybara)
(with Phantomjs driver) to interact with Velum.

## License

This project is licensed under the Apache License, Version 2.0. See
[LICENSE](https://github.com/kubic-project/automation/velum-bootstrap/blob/master/LICENSE) for the full
license text.
