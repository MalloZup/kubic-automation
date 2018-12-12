# Jenkins Job Definitions

## Jobs vs Job Templates vs Projects

Jobs are single use, exactly one copy of the job will be created. This is useful primarily for
our nightly jobs.

Job Templates are multi use, e.g. several projects might consume a code style job. These should
be a Job Template.

Projects are where instances of job templates are created, and applied to a given Git repo.

## Uploading Job Definitions to Jenkins

1. Copy and fill in the JJB config file:

   cp jenkins_jobs.ini.sample jenkins_jobs.ini
   vi jenkins_jobs.ini

Note: The password requested is the API Token for your user, found via the Jenkins UI on your user page.

2. Run Jenkins Job builder in test mode:

    tox -e test

The `output` folder will contain the generated XML job definitions to inspect.

3. Run Jenkins Job builder in update mode:

    tox -e update -- --conf jenkins_jobs.ini

All jobs will now have been created/updated on the Jenkins server.
