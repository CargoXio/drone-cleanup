#!/bin/sh

# Delete jobs 1 hour after they have been completed
timeout=$TTL_TIMEOUT
if [ -z "$timeout" ]; then
    timeout=3600
fi

# Note that Alpine / Busybox does not suppoer "-v"
# now=`date -v -${timeout}S -u +"%Y-%m-%dT%H:%M:%SZ"`
then="$(( `date +%s`-${timeout} ))"
now=`date -d@${then} -u +"%Y-%m-%dT%H:%M:%SZ"`

echo "*** Cleaning up Drone's leftovers. Deleting everything older than $now."

echo "=== Deleting jobs ==="
jobs=$(kubectl get jobs -o jsonpath='{range .items[?(@.status.completionTime)]}{.status.completionTime}{"|"}{.metadata.name}{"\n"}' | sort)
for i in $jobs; do
    time=$(echo "$i" | cut -f1 -d\|)
    name=$(echo "$i" | cut -f2 -d\|)

    if ! case $name in drone-job-*) ;; *) false;; esac; then
        echo "Skipping job $name, because not a drone job"
        continue
    fi
    if [ "`expr "$time" \> "$now"`" == "1" ]; then
        echo "Skipping job $name, because $time > $now"
        continue
    fi

    echo -n "Deleting job $name: "
    kubectl delete job $name
done

echo "=== Deleting pods ==="
pods=$(kubectl get pods --field-selector=status.phase!=Running --field-selector=status.phase!=Pending --field-selector=status.phase!=Pending -o jsonpath='{range .items[*]}{.status.startTime}{"|"}{.metadata.name}{"\n"}' | sort)
for i in $pods; do
    time=$(echo "$i" | cut -f1 -d\|)
    name=$(echo "$i" | cut -f2 -d\|)

    if ! case $name in drone-job-*) ;; *) false;; esac; then
        echo "Skipping pod $name, because not a drone job"
        continue
    fi
    if [ "`expr "$time" \> "$now"`" == "1" ]; then
        echo "Skipping pod $name, because $time > $now"
        continue
    fi

    echo -n ": Deleting pod $name"
    kubectl delete pod $name
done

