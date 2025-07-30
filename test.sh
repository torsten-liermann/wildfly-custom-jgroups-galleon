#!/bin/bash
# Test script to demonstrate Galleon limitations

GALLEON_HOME="${GALLEON_HOME:-/home/torsten/projects-akdb/galleon-6.0.6.Final}"

echo "Building feature pack..."
./mvnw clean install

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo -e "\n=== Test 1: Normal provisioning with web-clustering ==="
echo "This provisions both TCP and UDP stacks as expected"
rm -rf server-both-stacks
$GALLEON_HOME/bin/galleon.sh provision provisioning-examples/provision-with-both-stacks.xml \
    --dir=server-both-stacks

if [ -f server-both-stacks/standalone/configuration/standalone.xml ]; then
    echo "Checking stacks in configuration:"
    echo -n "TCP stack: "
    grep -c "stack name=\"tcp\"" server-both-stacks/standalone/configuration/standalone.xml
    echo -n "UDP stack: "
    grep -c "stack name=\"udp\"" server-both-stacks/standalone/configuration/standalone.xml
fi

echo -e "\n=== Test 2: No clustering (this works) ==="
rm -rf server-no-clustering
$GALLEON_HOME/bin/galleon.sh provision provisioning-examples/provision-no-clustering.xml \
    --dir=server-no-clustering

if [ -f server-no-clustering/standalone/configuration/standalone.xml ]; then
    echo "Checking for JGroups subsystem:"
    grep -c "urn:jboss:domain:jgroups" server-no-clustering/standalone/configuration/standalone.xml && \
        echo "FAIL: JGroups subsystem is present!" || echo "SUCCESS: No JGroups subsystem"
fi

echo -e "\n=== Test 3: TCP-only attempt with custom feature pack ==="
echo "This attempts to create a TCP-only configuration"
echo "Expected: Only TCP stack"
echo "Actual: Will likely fail or include both stacks"
rm -rf server-tcp-only
$GALLEON_HOME/bin/galleon.sh provision provisioning-examples/provision-tcp-only.xml \
    --dir=server-tcp-only 2>&1 | tail -5

echo -e "\n=== Results ==="
echo "1. Default provisioning: Both TCP and UDP stacks are present"
echo "2. No clustering: Works as expected - no JGroups subsystem"
echo "3. TCP-only attempt: Results in provisioning error"
echo ""
echo "The question remains: How can we achieve the desired configurations with Galleon?"