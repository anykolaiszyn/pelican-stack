# Pelican Panel Docker Compose Deployment (using ghcr.io/pelican-dev/panel)

This repository provides a one-click deployment for [Pelican Panel](https://github.com/pelican-dev/panel) using Docker Compose, based on their official Docker deployment guide.

**Note:** According to the Pelican Panel documentation, "Deploying the panel in Docker is still a work in progress. While the plan is to make Docker the preferred installation method, we currently recommend the standard deployment instructions." This setup follows their provided Docker guide.

## Features

- Deploys Pelican Panel using the `ghcr.io/pelican-dev/panel:latest` image.
- **Integrated Caddy Web Server:** Handles HTTP/S and can automatically obtain SSL certificates from Let's Encrypt.
- **SQLite Database:** Defaults to using an SQLite database, stored in a persistent volume. (External databases can be configured via the installer).
- Uses an internal bridge network.
- Utilizes named volumes for persistent data storage (`pelican-data`, `pelican-logs`).
- Configurable via environment variables in a `.env` file.
- Includes helper scripts (`init.sh`, `init.ps1`) to generate a `.env` file from `.env.example`.
- Compatible with Portainer stack import.

## Prerequisites

- [Docker CE](https://docs.docker.com/get-docker/) (Docker Compose v2 is included with Docker CLI)
- Git

## Quick Start

1.  **Clone the repository:**

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

2.  **Initialize and Configure Environment Variables:**

    Run the `init` script for your OS, or manually copy `.env.example` to `.env`.

    ```bash
    # For Linux/macOS
    ./scripts/init.sh
    # For Windows (PowerShell)
    .\scripts\init.ps1
    ```

    **Crucially, edit the `.env` file and set:**
    *   `APP_URL`: Your panel's public URL (e.g., `https://panel.example.com` or `http://localhost`). If using `https://`, Caddy will attempt to get an SSL certificate.
    *   `ADMIN_EMAIL`: Your email address, used by Caddy for Let's Encrypt registration.

3.  **Start the services:**

    ```bash
    docker compose up -d
    ```

4.  **Back Up Your Encryption Key:**

    The first time the container starts, it generates an `APP_KEY`. Back this up securely.
    ```bash
    docker compose logs panel | grep 'Generated app key:'
    ```
    *(You might need to wait a moment after starting for the key to be generated and logged).*

5.  **Complete Installation via Browser:**

    Open your browser and navigate to `YOUR_APP_URL/installer` (e.g., `http://localhost/installer` or `https://panel.example.com/installer`) to finish setting up the panel.
    The panel will use SQLite by default. Other drivers (cache, session, queue) also have sensible defaults.

    *Note: The first time the container starts after installing or updating, it will apply database migrations, which may take a few minutes. The panel will not be accessible during this process.*

## Configuration

### Environment Variables

Key variables in your `.env` file:

-   `APP_URL`: (Required) The base URL your panel will be reachable on (e.g., `https://panel.example.com`).
-   `ADMIN_EMAIL`: (Required) Your email, used by Caddy for Let's Encrypt.
-   `APP_PORT_HTTP` (Optional): External HTTP port. Defaults to `80`.
-   `APP_PORT_HTTPS` (Optional): External HTTPS port. Defaults to `443`.
-   `DOCKER_SUBNET` (Optional): Docker network subnet. Defaults to `172.20.0.0/16`.

### Default Drivers

-   **Cache Driver:** Filesystem
-   **Database Driver:** SQLite
-   **Queue Driver:** Database
-   **Session Driver:** Filesystem

For other configurations (UI, CAPTCHA, email, backups, OAuth, or external databases/Redis), use the settings menu in the admin panel after installation.

## Managing the Panel

-   **Stopping:**
    ```bash
    docker compose down
    ```
-   **Starting:**
    ```bash
    docker compose up -d
    ```
-   **Viewing Logs:**
    ```bash
    docker compose logs panel
    ```
-   **Uninstalling (Deletes all data!):**
    ```bash
    docker compose down -v
    ```

## Advanced Options

### Custom Caddyfile

If you need to customize the Caddy web server configuration (e.g., for use behind another reverse proxy that terminates TLS):

1.  Create a `Caddyfile` in the same directory as your `docker-compose.yml`.
2.  Uncomment the Caddyfile volume mount in `docker-compose.yml`:
    ```diff
    volumes:
      - pelican-data:/pelican-data
      - pelican-logs:/var/www/html/storage/logs
    - ./Caddyfile:/etc/caddy/Caddyfile # Uncomment this line
    ```
3.  Restart the panel: `docker compose up -d --force-recreate`

**Example `Caddyfile` for use behind a reverse proxy (TLS terminated upstream):**
Replace `[UPSTREAM IP]` with the IP address of your reverse proxy.

```caddy
{
    admin off
    servers {
        trusted_proxies static [UPSTREAM IP]
    }
}

:80 {
    root * /var/www/html/public
    encode gzip

    php_fastcgi 127.0.0.1:9000
    file_server
}
```
*Note: If the `trusted_proxies` directive is not set or improperly configured, file uploads may fail.*

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


## Portainer Stack Import

This `docker-compose.yml` is designed to be self-contained and can be directly used to deploy the stack in Portainer:

1.  In Portainer, navigate to "Stacks".
2.  Click "Add stack".
3.  Choose "Web editor" as the build method.
4.  Give your stack a name (e.g., `pelican-panel`).
5.  Copy the contents of `docker-compose.yml` from this repository and paste it into the web editor.
6.  Define the required environment variables (`APP_URL`, `ADMIN_EMAIL`) directly in Portainer under the "Environment variables" section. You can also set optional ones like `APP_PORT_HTTP`, `APP_PORT_HTTPS`, `DOCKER_SUBNET`.
7.  Click "Deploy the stack".

## Data Persistence

Named volumes are used to persist data:

-   `pelican-data`: Stores Pelican Panel application data, including the SQLite database, configurations, and other user-specific files (as per `XDG_DATA_HOME`).
-   `pelican-logs`: Stores Pelican Panel logs from `/var/www/html/storage/logs`.

These volumes are managed by Docker and will persist even if the containers are removed and recreated (unless you use `docker compose down -v`).

## Labels

The `docker-compose.yml` includes OCI standard labels for better metadata and discovery.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue.
