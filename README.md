# WildFly Custom JGroups Galleon Feature Pack Example

This repository demonstrates the challenge of modifying features from parent feature packs using Galleon.

## Problem Statement

We want to create a custom Galleon feature pack that provides three WildFly variants:
1. **No Clustering**: WildFly without JGroups
2. **TCP-Only Clustering**: WildFly with only TCP stack (no UDP)
3. **UDP-Only Clustering**: WildFly with only UDP stack (no TCP)

## Current Status

What we've found so far:
- ✓ We can add new features
- ✓ We can choose not to include certain layers (e.g., no clustering works)
- Our attempts to selectively include only TCP or UDP have not succeeded yet

We're looking for the right approach to achieve these configurations.

## Repository Structure

```
.
├── README.md
├── pom.xml
├── wildfly-feature-pack-build.xml
├── src/main/resources/
│   ├── feature_groups/
│   │   └── valid-attempt-tcp-only.xml    # TCP-only configuration attempt
│   └── layers/standalone/
│       ├── tcp-clustering/layer-spec.xml
│       └── no-clustering/layer-spec.xml
├── provisioning-examples/
│   ├── provision-with-both-stacks.xml    # Shows default behavior
│   ├── provision-tcp-only.xml            # TCP-only provisioning attempt
│   └── provision-no-clustering.xml       # Works
└── test-results/
    └── analysis.md

```

## Building the Feature Pack

```bash
./mvnw clean install
```

## Testing

### Test 1: Default WildFly with clustering
```bash
galleon.sh provision provisioning-examples/provision-with-both-stacks.xml --dir=server-default
# Result: Both TCP and UDP stacks are present
```

### Test 2: No clustering (works)
```bash
galleon.sh provision provisioning-examples/provision-no-clustering.xml --dir=server-no-clustering
# Result: No JGroups subsystem - this works as expected
```

### Test 3: TCP-only attempt
```bash
galleon.sh provision provisioning-examples/provision-tcp-only.xml --dir=server-tcp-only
# Result: Provisioning error
```

## The Core Question

How can we achieve these specific server configurations using Galleon's feature pack mechanism?

## Working Alternative

The only working approach for "no clustering" is simple - don't include the clustering layer:
```xml
<layers>
    <include name="cloud-server"/>
    <!-- Don't include web-clustering -->
</layers>
```

But this doesn't help for TCP-only or UDP-only configurations.

## Related Links

- [WildFly Galleon Documentation](https://docs.wildfly.org/galleon/)
- [Galleon GitHub](https://github.com/wildfly/galleon)