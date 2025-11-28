

# Podman Resource Management

The `podman resource` command allows you to manage and inspect system resources allocated for containers and pods in Podman on Windows. It supports listing available resources, setting limits, and querying current usage.

## Overview

When running Podman on Windows via WSL (Windows Subsystem for Linux), you may need to configure system resources to ensure optimal container performance. This guide covers the key resource management commands.## Subcommands

### 1. `podman resource list`

- **Description**: Displays the available CPUs, memory, and storage for containers and pods.
- **Usage**:

  ```powershell
  podman machine ls
  ```

- **Output**:
  - Information about available system resources.

### 2. `podman resource set`

- **Description**: Configures resource limits for Podman containers and pods.
- **Usage**:

  ```powershell
  podman resource set --cpus=<number> --memory=<size> --storage=<size>
  ```

- **Options**:
  - `--cpus=<number>`: Sets the maximum number of CPUs (e.g., `8`).
  - `--memory=<size>`: Specifies the memory limit in bytes or units like `MB`/`GB` (e.g., `8GB`).
  - `--storage=<size>`: Sets the storage limit in bytes or units like `MB`/`GB` (e.g., `40GB`).

### 3. `podman resource query`

- **Description**: Displays the current resource consumption and configured limits.
- **Usage**:

  ```powershell
  podman resource query
  ```

- **Output**:
  - Current resource usage and limits for CPUs, memory, and storage.

## Examples

### Example 1: List Available Resources

```powershell
podman machine ls
```

### Example 2: Configure Resource Limits

#### Stop the Machine and Adjust Resources

```powershell
podman machine stop
podman resource set --cpus=8 --memory=8192 --disk-size=40
podman machine start
```

#### Initialize Machine with Custom Resources

```powershell
podman machine init --cpus=8 --memory=8192 --disk-size=40
podman machine start
```

## Notes

- Use these commands to optimize system resource usage and prevent overcommitment.
- **Permissions**: Admin privileges might be required to set or adjust resource limits.
- These commands are particularly useful in environments with limited system resources.

## Additional Resources

- [Podman Official Documentation](https://podman.io/)
- [Podman GitHub Repository](https://github.com/containers/podman)