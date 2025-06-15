# Pelican Panel Docker Compose Deployment (for Portainer & Standalone)

This repository provides a streamlined Docker Compose setup for [Pelican Panel](https://github.com/pelican-dev/panel), based on their official Docker deployment guide. **The primary goal is to simplify deployment, especially for Portainer users, allowing you to connect this repository as a Git stack in Portainer and deploy a working Pelican Panel instance that is ready for its initial web-based configuration.**

**Note:** According to the Pelican Panel documentation, "Deploying the panel in Docker is still a work in progress. While the plan is to make Docker the preferred installation method, we currently recommend the standard deployment instructions." This setup follows their provided Docker guide.

## Features

- Deploys Pelican Panel using the `ghcr.io/pelican-dev/panel:latest` image.
- **Optimized for Portainer Git Stacks:** Easily deploy and manage Pelican Panel by pointing Portainer to this repository.
- **Integrated Caddy Web Server:** Handles HTTP/S and can automatically obtain SSL certificates from Let's Encrypt.
- **SQLite Database:** Defaults to using an SQLite database, stored in a persistent volume. (External databases can be configured via the installer).
- Uses an internal bridge network.
- Utilizes named volumes for persistent data storage (`pelican-data`, `pelican-logs`).
- Configurable via environment variables in a `.env` file.
- Includes helper scripts (`init.sh`, `init.ps1`) to generate a `.env` file from `.env.example`.
- Compatible with Portainer stack import (both via Git and web editor).

## Prerequisites

- [Docker CE](https://docs.docker.com/get-docker/) (Docker Compose v2 is included with Docker CLI)
- Git

## Quick Start

(For standalone Docker Compose users. Portainer users, see the "Portainer Stack Import" section below.)

1. **Clone the repository:**

    You can clone the repository using HTTPS with a Personal Access Token (PAT) or by using SSH.

    **Using HTTPS with a Personal Access Token (PAT):**

    If you don't have a PAT, create one by following the [GitHub documentation on creating a PAT](https://github.com/settings/tokens) with the `repo` scope.

    ```bash
    git clone https://YOUR_USERNAME:YOUR_PAT@github.com/anykolaiszyn/pelican-stack.git # Replace with your username and PAT
    cd pelican-stack
    ```

    **Alternatively, using SSH:**

    Ensure you have an SSH key added to your GitHub account. You can find instructions in the [GitHub documentation on adding an SSH key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

    ```bash
    git clone git@github.com:anykolaiszyn/pelican-stack.git
    cd pelican-stack
    ```

2. **Initialize and Configure Environment Variables:**

    Run the `init` script for your OS, or manually copy `.env.example` to `.env`.

    ```bash
    # For Linux/macOS
    ./scripts/init.sh
    # For Windows (PowerShell)
    .\\scripts\\init.ps1
    ```

    **Crucially, edit the `.env` file and set:**
    - `APP_URL`: Your panel's public URL (e.g., `https://panel.example.com` or `http://localhost`). If using `https://`, Caddy will attempt to get an SSL certificate.
    - `ADMIN_EMAIL`: Your email address, used by Caddy for Let's Encrypt registration.

3. **Start the services:**

    ```bash
    docker compose up -d
    ```

4. **Back Up Your Encryption Key:**

    The first time the container starts, it generates an `APP_KEY`. Back this up securely.

    ```bash
    docker compose logs panel | grep 'Generated app key:'
    ```

    *(You might need to wait a moment after starting for the key to be generated and logged).*

5. **Complete Installation via Browser:**

    Open your browser and navigate to `YOUR_APP_URL/installer` (e.g., `http://localhost/installer` or `https://panel.example.com/installer`) to finish setting up the panel.
    The panel will use SQLite by default. Other drivers (cache, session, queue) also have sensible defaults.

    *Note: The first time the container starts after installing or updating, it will apply database migrations, which may take a few minutes. The panel will not be accessible during this process.*

## Portainer Stack Import

This setup is ideal for deploying Pelican Panel as a stack in Portainer using its Git repository feature, but can also be used by copying the `docker-compose.yml` content.

### Method 1: Using Git Repository (Recommended for easy updates)

1. In Portainer, navigate to "Stacks".
2. Click "Add stack".
3. Select "Git repository" as the build method.
4. Give your stack a name (e.g., `pelican-panel`).
5. **Repository URL:** `https://github.com/anykolaiszyn/pelican-stack.git`
6. **Compose path:** `docker-compose.yml` (this should be the default)
7. **Branch/Reference:** `main` (or your preferred branch)
8. Enable "Automatic updates" if desired (Portainer can periodically pull changes from this Git repository).
9. Under "Environment variables", define the required variables:
    - `APP_URL`: Your panel's public URL (e.g., `https://panel.example.com`).
    - `ADMIN_EMAIL`: Your email address (for Let's Encrypt).
    - Optionally, add `APP_PORT_HTTP`, `APP_PORT_HTTPS`, `DOCKER_SUBNET` if you need to override defaults.

10. Click "Deploy the stack".

### Method 2: Using Web Editor

1. In Portainer, navigate to "Stacks".
2. Click "Add stack".
3. Choose "Web editor" as the build method.
4. Give your stack a name (e.g., `pelican-panel`).
5. Copy the contents of `docker-compose.yml` from this repository and paste it into the web editor.
6. Define the required environment variables (`APP_URL`, `ADMIN_EMAIL`) directly in Portainer under the "Environment variables" section. You can also set optional ones like `APP_PORT_HTTP`, `APP_PORT_HTTPS`, `DOCKER_SUBNET`.
7. Click "Deploy the stack".

Once deployed, proceed to the "Back Up Your Encryption Key" and "Complete Installation via Browser" steps mentioned in the Quick Start section (steps 4 and 5).

## Configuration

### Environment Variables

Key variables in your `.env` file (or defined in Portainer stack environment variables):

- `APP_URL`: (Required) The base URL your panel will be reachable on (e.g., `https://panel.example.com`).
- `ADMIN_EMAIL`: (Required) Your email, used by Caddy for Let's Encrypt.
- `APP_PORT_HTTP` (Optional): External HTTP port. Defaults to `80`.
- `APP_PORT_HTTPS` (Optional): External HTTPS port. Defaults to `443`.
- `DOCKER_SUBNET` (Optional): Docker network subnet. Defaults to `172.20.0.0/16`.

### Default Drivers

- **Cache Driver:** Filesystem
- **Database Driver:** SQLite
- **Queue Driver:** Database
- **Session Driver:** Filesystem

For other configurations (UI, CAPTCHA, email, backups, OAuth, or external databases/Redis), use the settings menu in the admin panel after installation.

## Managing the Panel

(These commands are for standalone Docker Compose. For Portainer, manage the stack through its UI.)

- **Stopping:**

    ```bash
    docker compose down
    ```

- **Starting:**

    ```bash
    docker compose up -d
    ```

- **Viewing Logs:**

    ```bash
    docker compose logs panel
    ```

- **Uninstalling (Deletes all data!):**

    ```bash
    docker compose down -v
    ```

## Advanced Options

### Using Pelican Panel Behind a Reverse Proxy

If you plan to run Pelican Panel behind another reverse proxy (like Nginx, Traefik, or your cloud provider's load balancer), you'll need to ensure Caddy (the web server integrated into the Pelican image) is configured correctly to understand it's operating in such an environment. This is crucial for correct URL generation, IP address logging, and SSL handling.

**Key Considerations:**

1. **`APP_URL`**: Ensure the `APP_URL` environment variable is set to the final public-facing URL (e.g., `https://pelican.yourdomain.com`), even if the reverse proxy is handling SSL termination.
2. **SSL Termination**:
    - **If your reverse proxy terminates SSL (handles HTTPS)**: You'll configure Caddy to listen on HTTP, and your reverse proxy will forward requests to it.
    - **If Caddy handles SSL**: Your reverse proxy will pass through HTTPS traffic to Caddy.
3. **Forwarded Headers**: The reverse proxy must correctly send headers like `X-Forwarded-For` (for the original client IP) and `X-Forwarded-Proto` (for the original scheme, e.g., `https`). Caddy needs to be configured to trust these headers from your proxy.

#### Custom Caddyfile for Reverse Proxy Scenarios

To customize Caddy's behavior, you'll use a custom `Caddyfile`.

1. Create a `Caddyfile` in the root of this project (same directory as `docker-compose.yml`).
2. Uncomment the Caddyfile volume mount in `docker-compose.yml`:

    ```diff
    volumes:
      - pelican-data:/pelican-data
      - pelican-logs:/var/www/html/storage/logs
    # - ./Caddyfile:/etc/caddy/Caddyfile # Uncomment this line
    ```

3. Restart the panel: `docker compose up -d --force-recreate` (or redeploy the stack in Portainer).

#### Example 1: Reverse Proxy Terminates SSL (Most Common)

If your external reverse proxy (e.g., Nginx, Traefik) handles HTTPS and forwards plain HTTP traffic to the Pelican container:

- Your `APP_URL` should still be `https://...`.
- Your reverse proxy should be configured to forward requests to the Pelican container on its HTTP port (default 80, or `APP_PORT_HTTP` if set).
- The `Caddyfile` should instruct Caddy to trust your proxy.

**`Caddyfile` content:**
Replace `[IP_OF_YOUR_REVERSE_PROXY]` with the actual IP address of your reverse proxy. If your proxy is on the same Docker network, you might use its service name or container IP.

```caddy
{
    # Tell Caddy to trust X-Forwarded-* headers from your reverse proxy
    # This is crucial for Caddy to know the original client IP and protocol (http/https)
    servers {
        trusted_proxies static [IP_OF_YOUR_REVERSE_PROXY]
    }
    # Disable Caddy's own admin API if not needed
    admin off
}

# Listen on port 80 (Caddy's internal HTTP port)
# Your APP_URL should be set to the public HTTPS address
{$APP_URL:80} { # This uses the host from APP_URL but forces port 80 for listening
    root * /var/www/html/public
    encode gzip
    php_fastcgi 127.0.0.1:9000
    file_server

    # Optional: Add custom headers or other Caddy directives here
}
```

*Note: If the `trusted_proxies` directive is not set or improperly configured, file uploads may fail, and IP logging might be incorrect.*

#### Example 2: Reverse Proxy Passes Through HTTPS (Caddy Handles SSL)

If your reverse proxy is simply passing TCP traffic for port 443 to the Pelican container (less common if you already have a proxy):

- Your `APP_URL` will be `https://...`.
- `ADMIN_EMAIL` must be set for Let's Encrypt.
- Your reverse proxy should forward TCP traffic for port 443 (and 80 for HTTP->HTTPS redirects) to the Pelican container.
- The default Caddy configuration within the image might work, or you might need a minimal `Caddyfile` if you have specific needs. If `APP_URL` is set to `https://...` and `ADMIN_EMAIL` is provided, Caddy will attempt automatic HTTPS.

In this scenario, a custom `Caddyfile` might only be needed for advanced settings, not specifically for the reverse proxy interaction itself, as Caddy would behave as if it's directly facing the internet.

**Important:**

- Always ensure your reverse proxy is configured to pass the `Host` header correctly to the Pelican container, matching the `APP_URL`.
- After changing `docker-compose.yml` or `Caddyfile`, always redeploy/recreate the container(s).

### Custom Caddyfile

If you need to customize the Caddy web server configuration for reasons other than a standard reverse proxy setup (e.g., adding custom directives, headers, or specific TLS settings when Caddy itself handles SSL):

1. Create a `Caddyfile` in the same directory as your `docker-compose.yml` (if running standalone) or ensure it's in the Git repository if using Portainer Git deployment.
2. Uncomment the Caddyfile volume mount in `docker-compose.yml`:

    ```diff
    volumes:
      - pelican-data:/pelican-data
      - pelican-logs:/var/www/html/storage/logs
      - ./Caddyfile:/etc/caddy/Caddyfile # Ensure this line is uncommented
    ```

3. Restart the panel: `docker compose up -d --force-recreate` (or redeploy the stack in Portainer).

**Example `Caddyfile` for general customization (e.g., if Caddy handles SSL directly):**
This example assumes Caddy is obtaining SSL certificates.

```caddy
{
    # Optional: Disable Caddy's admin API if not needed
    admin off
    # Optional: Configure ACME DNS challenge if needed, or other global options
}

{$APP_URL} { # This uses the APP_URL directly
    root * /var/www/html/public
    encode gzip
    php_fastcgi 127.0.0.1:9000
    file_server

    # Add any other custom Caddy directives here
    # e.g., custom headers, redirects, security settings
}
```

*Previously, this section contained an example for a reverse proxy where TLS was terminated upstream. That example has been expanded and moved to the dedicated "Using Pelican Panel Behind a Reverse Proxy" section above.*

### Raising File Upload Limits

To raise the default 2MB file upload limit, modify your custom `Caddyfile`:

```caddy
yourdomain.com_or_localhost { # Replace with your APP_URL host or remove if using a global block
    # ... other Caddy settings ...

    encode gzip

    php_fastcgi 127.0.0.1:9000 {
        env PHP_VALUE "upload_max_filesize = 256M
                       post_max_size = 256M"
    }
    file_server

    # ... other Caddy settings ...
}
```

If you are not using a specific domain in your Caddyfile (e.g. just `:80`), you can place the `php_fastcgi` block inside the site block like so:

```caddy
:80 {
    # ... other Caddy settings ...
    encode gzip

    php_fastcgi 127.0.0.1:9000 {
        env PHP_VALUE "upload_max_filesize = 256M
                       post_max_size = 256M"
    }
    file_server
    # ... other Caddy settings ...
}
```

## Data Persistence

Named volumes are used to persist data:

- `pelican-data`: Stores Pelican Panel application data, including the SQLite database, configurations, and other user-specific files (as per `XDG_DATA_HOME`).
- `pelican-logs`: Stores Pelican Panel logs from `/var/www/html/storage/logs`.

These volumes are managed by Docker and will persist even if the containers are removed and recreated (unless you use `docker compose down -v` or remove the stack with volumes in Portainer).

## Labels

The `docker-compose.yml` includes OCI standard labels for better metadata and discovery.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue.
