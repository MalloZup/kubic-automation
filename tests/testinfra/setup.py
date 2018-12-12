from setuptools import setup, find_packages
from os import path

setup(
    name='testinfra-tests',
    version='0.0.0',
    description='CaaSP Testinfra Tests',
    packages=find_packages(exclude=['tools']),
)
