# Test Results Analysis

## Summary of Attempts

### Attempt 1: Using `origin` attribute
**File**: `feature_groups/attempt1-tcp-only-with-origin.xml`
**Result**: Parser error
```
Unexpected attribute 'origin' encountered
```
**Analysis**: The `origin` attribute seems to not be supported in child feature packs, even though it's used in `domain-ec2-full-ha.xml` within the WildFly EE feature pack itself.

### Attempt 2: Reference parent feature groups with excludes
**File**: `feature_groups/attempt2-tcp-only-excludes.xml`
**Result**: Missing context error
```
Non-nillable parameter socket-binding-group of 
{wildfly-ee@maven(org.jboss.universe:community-universe)}socket-binding-group.socket-binding 
has not been initialized
```
**Analysis**: Feature groups from parent packs need context that we're not providing. The socket binding definitions require a socket-binding-group context.

### Attempt 3: Complete redefinition
**File**: `feature_groups/attempt3-tcp-only-complete.xml`
**Result**: Feature spec errors
```
Feature spec subsystem.jgroups does not define parameter default-stack
```
or
```
Failed to locate feature spec 'subsystem.jgroups.stack.socket-protocol'
```
**Analysis**: Even when trying to completely redefine features, we run into issues with feature spec definitions that may be internal to WildFly.

### Attempt 4: Excludes in provisioning.xml
**File**: `provisioning-examples/provision-tcp-only-attempt2.xml`
**Result**: Excludes are silently ignored
**Analysis**: The provisioning configuration doesn't support exclude elements, they are simply ignored without error.

## Core Finding

The exclude mechanism in Galleon only works within the same feature pack where the features are originally defined. Cross-feature-pack excludes are not supported.

## Working Example

The only approach that works is for "no clustering":
```xml
<layers>
    <include name="cloud-server"/>
    <!-- Don't include web-clustering -->
</layers>
```

But this doesn't help for TCP-only or UDP-only configurations where we need to selectively exclude parts of the clustering subsystem.