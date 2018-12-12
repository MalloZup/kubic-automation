# Kubernetes pod creationg and scaling-up tests

The yaml file(s) in the yaml/ directory are used to create test pods
and then scale them up by increasing the number of replicas.
The test is handled by Jenkins using the podName, replicaCount, and
replicasCreationInterval build parameters.

Use the k8s-pod-tests script for manual testing.

See the jenkins-library repository for automated testing.

## CLI Syntax

    Usage:

      * List pods

        -l|--list                                      List running pods

      * Creating a pod

        -c|--create          <MANIFEST_FNAME>          Create a pod using a manifest file

      * Deleting a pod

        -d|--delete          <MANIFEST_FNAME>          Delete a pod using a manifest file

      * Scaling up a pod

        -s|--scale           <NAME> <NUM>              Set the number of replicas
        --slowscale          <NAME> <NUM> <TIME>       Scale up to a number of replicas over an amount of time
                                                       <TIME> is the total time in seconds
            [-w|--wait]                                Optional: wait for replicas to be available

    * General Options

        -e|--environment     <FNAME>                   Set path to environment.json
        -k|--kubeconfig      <FNAME>                   'kubeconfig' file path (defaults to value from environment.json)

      * Examples:

      ./k8s-pod-tests -l
      ./k8s-pod-tests --create default

    Requirements:
     - 'kubeconfig' file
     - 'kubectl' executable in path
