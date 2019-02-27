Remove finished drone jobs and pods from cluster
================================================

Why
---

We've created this simple image and corresponding files to deal with the fact that
[Drone](https://drone.io/) does not clean up jobs after itself.

[Official documentation](https://docs.drone.io/installation/github/kubernetes/#job-cleanup)
will tell you to enable `TTLAfterFinished` [feature gate](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/).

However, for some, that's simply not possible, as the [TTL controller](https://kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/)
is available only from Kubernetes v1.12 on. And it's alpha so it's bound to change.

If you're on older version (e.g. [kops only supports 1.11](https://github.com/kubernetes/kops/releases)),
you're left out in the dark.


How
---

This is a simple script which should be scheduler to run on your cluster every now and then -
suggested timeout is 10 minutes, but you can set it to anything you like. Please see the attached
example for more info.

Please note that you'll need to deploy a service account with this tool to access your cluster
from inside the pod, if you have RBAC enabled.


Configuration
=============

Nothing much to configure. Defaults should work in most cases. However, if you have any specifics,
you can set up the following environment variables:
- `TTL_TIMEOUT` timeout after which completed jobs and pods are deleted. By default it's set to
  `3600` seconds - so jobs and pods get cleared out after one hour.


Installation
============

```
kubectl apply -f drone-cleanup.yml
```

Please make sure that you set an appropriate namespace (`drone`, by default) in `drone-cleanup.yml`
as the script will look for jobs in the current namespace only.