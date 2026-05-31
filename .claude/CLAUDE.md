## Local User Review of Code Changes

The `/difit` skill covers normal usage; two extra habits make seeding review comments
reliable across versions:

- **Seed comments live, not at startup.** Start with `--clean`, then add them with
  `difit comment add --port <port> '<array>'` once the server is up (takes an object or an
  array). The live API is dependable; the startup `--comment` path has not been.
- **Pin the host to IPv4: `--host 127.0.0.1`.** `difit comment add` connects over IPv4, so
  relying on difit's default bind risks an IPv6-only (`[::1]`) server the injector can't
  reach.

So: run difit as a background task — `difit <target> [base] --clean --no-open --host
127.0.0.1` — wait for it, then inject. Pass the array from a file (`"$(cat comments.json)"`)
so backticks/quotes in bodies survive the shell; a `{"success":true,"warnings":[]}` reply
confirms it took.
