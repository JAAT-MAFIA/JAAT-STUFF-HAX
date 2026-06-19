# JAAT STUFF HAX

Remote control panel for JAAT STUFF BGMI lib.


## config.json Fields

| Field | Type | Description |
|-------|------|-------------|
| version | string | Latest version. Older users get update toast |
| kill_switch | bool | true = lib DISABLED for ALL users |
| kill_message | string | Shown on kill screen |
| update_msg | string | Shown in update notification |
| notice | string | Broadcast to all users. Empty = hidden |
| download_url | string | Link to latest update (used in update toast button) |


## Kill Switch Usage

Set kill_switch to true to disable the lib for all users.
Set kill_switch to false to re-enable.
Takes effect within 5 minutes.


## Config Raw URL
https://raw.githubusercontent.com/JAAT-MAFIA/JAAT-STUFF-HAX/main/config.json
