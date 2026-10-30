# Wake-up CLI — We've Got Numbers to Crunch

A little Linux playground with **Codex CLI** installed. You can ask Codex to write code, or just use the terminal like a normal Linux computer. While the container is running, it also tries to send Codex a `hello` every five hours.

**You do not need to understand Docker to use this.** Copy the commands below into a terminal opened in this project's folder.

## What you need

- A computer with **Docker + Docker Compose** installed. **Podman + podman-compose** can also work.
- `make` installed.
- Internet access and a ChatGPT account with access to Codex.
- This project's `Dockerfile`, `compose.yml`, `Makefile`, and `cron-ping.sh` in the same folder.

## The five commands you actually need

| What you want | Type this |
|---|---|
| Build and start everything | `make` |
| Talk to Codex | `make codex` |
| Open a normal Linux terminal inside the container | `make shell` |
| Stop everything without losing your files | `make down` |
| See whether it's running | `docker compose ps` |

**First time?** Follow the next section once.

## First-time setup

### Step 1 — Open a terminal in the project folder

You should see the `Makefile` when you type `ls`.

### Step 2 — Start it

```bash
make
```

The first build may take a few minutes. Wait for it to finish. The container runs in the background.

### Step 3 — Connect your ChatGPT account (only once per saved login)

```bash
make shell
codex login --device-auth
```

Codex will show a website and a one-time code. Open the website **on your own browser**, sign in, enter the code, and **wait until the terminal confirms success**. Do not press Ctrl+C during login.

Check that it worked:

```bash
codex login status
```

**Already logged in?** Skip `codex login --device-auth` next time. Your browser login and the container's Codex login are separate.

To leave this inner terminal, type:

```bash
exit
```

### Step 4 — Ask Codex to do something

From the project folder on your normal computer:

```bash
make codex
```

Type a request, such as:

> Create a tiny C++98 Hello World project, compile it, and explain what you did.

Press Enter. Codex may ask permission before running commands or editing files.

To leave Codex, type `/exit`.

## It's also a regular Linux terminal

Run:

```bash
make shell
```

Now you're inside the container. For example:

```bash
pwd                 # Where am I?
ls                  # Show files
mkdir my-project    # Create a folder
cd my-project       # Enter that folder
python3 --version   # Check Python
codex               # Launch Codex here
```

Type `exit` to return to your normal computer. Commands inside this terminal run **inside the container**, not directly on your host. You have the permissions of the container's non-root user.

## Where did my files go?

Your working area is `/workspace` inside the container. The Compose configuration saves it in a **named volume**, so normal stops and rebuilds do not erase it. Your Codex login is saved in a separate volume.

**Important:** a Docker volume is not automatically a folder you can browse in your host's home directory. To see the files, use `make shell`. Back up important work or push it to Git; a volume is not a backup.

## The automatic five-hour hello

While the container is running, its built-in scheduler waits **five hours after startup**, sends `hello` to Codex, and then repeats after each five-hour wait. It does **not** run while the container is stopped. Restarting the container restarts the countdown.

To see the log:

```bash
make shell
cat ~/logs/codex-ping.log
```

The scheduler writes success or failure messages. A running container **does not guarantee** that Codex is authenticated or that requests succeed. A `hello` request consumes some Codex usage; it does not bank extra quota or extend your allowance.

## Stop, restart, or clean up

| Command | What happens | Do I keep my workspace and login? |
|---|---|---|
| `make down` | Stops and removes the container | **Yes** |
| `make` | Builds/starts it again | **Yes** |
| `make clean` | Removes container and image | **Yes** |
| `make re` | Rebuilds and restarts | **Yes** |
| `make vclean` | Removes container and volumes | **NO** |
| `make fclean` | Removes container, image, and volumes | **NO** |

**DANGER: `make vclean` and `make fclean` permanently delete the saved workspace and login volumes.** You will lose unsaved projects and need to sign in again. Do not run these unless you mean it.

After `make clean` or `make fclean`, run `make` before trying `make shell`.

## If something doesn't work

**`no container ... found`** — You probably stopped or deleted it. Run `make`, then `make shell`.

**`Not logged in`** — Run `make shell`, then `codex login --device-auth`, and finish the browser steps. If you deleted volumes, you must sign in again.

**`make codex` fails** — Check `docker compose ps`, then `make shell` and `codex login status`.

**No automatic ping yet** — It waits five hours before the first one. Look at `~/logs/codex-ping.log` inside the container.

**Podman messages mentioning Docker** — Your system may be using Podman as a Docker-compatible replacement. That message alone is not a failure.

**Need more detail?** Run `docker compose logs --tail=100` on the host, and check `~/logs/codex-ping.log` inside the container.

## A few safety rules

- Don't put passwords or ChatGPT credentials into the Dockerfile, Git repository, or shared images.
- Codex can create, edit, and delete files it has permission to access. Review important changes before approving them.
- The container is useful isolation, **not** a perfectly secure virtual machine.
- Do not mount your host's Docker/Podman socket or sensitive directories unless you understand the risks.
- Your ChatGPT/Codex usage limits still apply to both your requests and scheduled pings.

**TL;DR:** `make` → sign in once → `make codex` → ask for code → `/exit` → `make down`.
