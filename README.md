# WildFly Custom JGroups Galleon Feature Pack Example

This repository demonstrates an attempt to create custom WildFly configurations using Galleon feature packs.

## Goal

Create a custom Galleon feature pack that provides three WildFly variants:
1. **No Clustering**: WildFly without JGroups
2. **TCP-Only Clustering**: WildFly with only TCP stack (no UDP)
3. **UDP-Only Clustering**: WildFly with only UDP stack (no TCP)

## Approach

This example attempts to use Galleon's exclude mechanism to remove unwanted JGroups stacks from the wildfly-ee-galleon-pack that we depend on.

## Current Finding

The exclude mechanism does not work across feature pack boundaries. We cannot:
- Reference feature groups from dependency feature packs using `origin` attribute
- Exclude features that are defined in dependency feature packs
- Modify configurations from dependency feature packs declaratively

## Repository Structure

```
.
├── README.md
├── pom.xml
├── wildfly-feature-pack-build.xml
├── src/main/resources/
│   ├── feature_groups/
│   │   ├── tcp-only-stack.xml            # TCP-only configuration
│   │   └── udp-only-stack.xml            # UDP-only configuration
│   ├── configs/standalone/
│   │   ├── standalone-tcp-only.xml       # Config referencing tcp-only feature group
│   │   ├── standalone-udp-only.xml       # Config referencing udp-only feature group
│   │   └── standalone-no-clustering.xml  # Config without clustering
│   └── layers/standalone/
│       ├── tcp-clustering/layer-spec.xml
│       └── no-clustering/layer-spec.xml
└── provisioning-examples/
    └── custom-feature-pack-only.xml      # Provision using only our feature pack

```

## Building the Feature Pack

```bash
./mvnw clean install
```

## Testing

```bash
# Provision a server using only our custom feature pack
galleon.sh provision provisioning-examples/custom-feature-pack-only.xml --dir=server-custom

# Check the configuration
grep -E "stack name=\"(tcp|udp)\"" server-custom/standalone/configuration/standalone-tcp-only.xml
```

## Key Files

### wildfly-feature-pack-build.xml  
Uses transitive dependency with `default-configs inherit="false"` to avoid inheriting standard configurations.

### feature_groups/tcp-only-stack.xml
Shows that we cannot reference feature groups from dependency feature packs - the `origin` attribute is not supported in this context.

### The Core Question
Is it possible to declaratively exclude features (like JGroups stacks) from dependency feature packs, or must this be done post-provisioning with CLI scripts?

## Related Links

- [WildFly Galleon Documentation](https://docs.wildfly.org/galleon/)
- [Galleon GitHub](https://github.com/wildfly/galleon)