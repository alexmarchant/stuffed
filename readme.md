# Stuffed

Stuffed blocks websites on OSX. Think a command line version of Self-Control.

## Install

```
gem install stuffed
```

## Usage

`stuffed add reddit.com` - adds reddit.com & www.reddit.com to the blocked list.

`stuffed remove reddit.com` - removes reddit.com & www.reddit.com from the blocked list.

`stuffed list` - lists all sites being blocked.

`stuffed off` - toggles blocking off.

`stuffed on` - toggles blocking on.

## Details

Stuffed edits your `/etc/hosts` file so most of the time you'll need to run `sudo stuffed <task>`.

There is some OSX specific code to flush the DNS cache, I haven't tried or tested any other OS's.

If you run into issues, there was a backup of the hosts file created at `/etc/hosts.backup`.
