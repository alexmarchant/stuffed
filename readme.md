# Stuffed

Stuffed blocks websites on OSX. Think a command line version of Self-Control.

## Install

```
gem install stuffed
```

## Usage

`add reddit.com` - adds 'reddit.com' & 'www.reddit.com' to the blocked list.

`remove reddit.com` - removes 'reddit.com' & 'www.reddit.com' from the blocked list.

`list` - lists all sites being blocked.

`off` - toggles blocking off.

`on` - toggles blocking on.

## Details

Stuffed edits your `/etc/hosts` file so most of the time you'll need to run `sudo stuffed <task>`.

There is some OSX specific code to flush the DNS cache, I haven't tried or tested any other OS's.

If you run into issues, there was a backup of the hosts file created at `/etc/hosts.backup`.
