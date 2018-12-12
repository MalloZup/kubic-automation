# CaaSP Bare metal deployment scripts

This directory contains the bare metal deployment script.

## Requirements

The script requires the Bare Metal Manager (BMM) service to run on a dedicated host.
The BMM acts as a proxy for the IPMI/iLO tools, pulls ISO images, schedules
available hardware.

## CLI Syntax

Setup deployer env

    > cd deployer; ./deployer

Run script manually and explore options:

    > ~/py3venv/bin/python3 ./deploy_testbed.py -h
