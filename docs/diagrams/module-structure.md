# Module Structure Diagram

```mermaid
graph TD
    subgraph "Module Categories"
        A[modules/] --> B[applications/]
        A --> C[core/]
        A --> D[desktop/]
        A --> E[hardware/]
        A --> F[network/]
        A --> G[services/]
        A --> H[users/]
    end

    subgraph "Applications"
        B --> B1[desktop-*.nix<br/>GUI Applications]
        B --> B2[cli-*.nix<br/>Command Line Tools]
        B --> B3[dev-*.nix<br/>Development Tools]
        B --> B4[game-*.nix<br/>Gaming Applications]
    end

    subgraph "Core"
        C --> C1[boot.nix]
        C --> C2[nix.nix]
        C --> C3[security.nix]
        C --> C4[shell/<br/>Shell Environment]
    end

    subgraph "Services"
        G --> G1[sys-*.nix<br/>System Services]
        G --> G2[web-*.nix<br/>Web Services]
        G --> G3[media-*.nix<br/>Media Services]
        G --> G4[mon-*.nix<br/>Monitoring]
        G --> G5[storage-*.nix<br/>Storage Services]
        G --> G6[sec-*.nix<br/>Security Services]
        G --> G7[dev-*.nix<br/>Dev Services]
        G --> G8[net-*.nix<br/>Network Services]
    end

    style A fill:#f9f,stroke:#333,stroke-width:4px
    style B fill:#bbf,stroke:#333,stroke-width:2px
    style C fill:#bfb,stroke:#333,stroke-width:2px
    style D fill:#fbf,stroke:#333,stroke-width:2px
    style E fill:#ffb,stroke:#333,stroke-width:2px
    style F fill:#bff,stroke:#333,stroke-width:2px
    style G fill:#fbb,stroke:#333,stroke-width:2px
    style H fill:#bfb,stroke:#333,stroke-width:2px
```

## Module Naming Patterns

```mermaid
graph LR
    subgraph "Naming Convention"
        A[Category] --> B[Prefix]
        B --> C[Purpose]
        C --> D[.nix]
    end

    subgraph "Examples"
        E1[applications/] --> F1[desktop-]
        F1 --> G1[firefox]
        G1 --> H1[.nix]

        E2[services/] --> F2[web-]
        F2 --> G2[nginx]
        G2 --> H2[.nix]

        E3[hardware/] --> F3[hw-]
        F3 --> G3[gpu-amd]
        G3 --> H3[.nix]
    end

    style A fill:#f9f,stroke:#333,stroke-width:2px
    style B fill:#bbf,stroke:#333,stroke-width:2px
    style C fill:#bfb,stroke:#333,stroke-width:2px
    style D fill:#fbf,stroke:#333,stroke-width:2px
```

## Module Dependencies

```mermaid
graph TD
    subgraph "Dependency Hierarchy"
        A[Host Configuration] --> B[Profiles]
        B --> C[Modules]
        C --> D[Core Modules]

        B --> E[desktop/gnome.nix]
        E --> F[desktop-*.nix modules]
        E --> G[applications/desktop-*.nix]
        E --> H[services/sys-audio.nix]

        C --> I[services/web-nginx.nix]
        I --> J[core/certificates.nix]
        I --> K[network/net-firewall.nix]

        C --> L[services/storage-minio.nix]
        L --> M[core/secrets.nix]
        L --> K
    end

    style A fill:#f9f,stroke:#333,stroke-width:4px
    style B fill:#bbf,stroke:#333,stroke-width:3px
    style C fill:#bfb,stroke:#333,stroke-width:2px
    style D fill:#fbf,stroke:#333,stroke-width:2px
```

## Service Module Categories

```mermaid
pie title Service Module Distribution
    "System Services (sys-*)" : 3
    "Web Services (web-*)" : 2
    "Media Services (media-*)" : 6
    "Monitoring (mon-*)" : 2
    "Storage Services (storage-*)" : 2
    "Security Services (sec-*)" : 1
    "Development Services (dev-*)" : 1
    "Network Services (net-*)" : 1
```

## Module Migration Flow

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Script as Migration Script
    participant Git as Git Repository
    participant Nix as Nix Configuration

    Dev->>Script: Run migrate-module-names.sh
    Script->>Git: Check for clean working tree
    Script->>Script: Read module rename mappings

    loop For each module
        Script->>Git: git mv old-name.nix new-name.nix
        Script->>Nix: Update import statements
        Script->>Script: Log changes
    end

    Script->>Script: Generate migration report
    Script->>Dev: Show completion status
    Dev->>Nix: nix flake check
    Dev->>Git: git commit changes
```

These diagrams illustrate:
1. The overall module structure and organization
2. The naming convention pattern
3. Module dependency relationships
4. Distribution of service modules by category
5. The migration process workflow
