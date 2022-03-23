# MacOS iMessage Attachment Cleaner

## Features
* Quickly trash iMessage attachments by file extension
* Easily backup and restore deleted files and reinstall if you feel like you'll miss them


## Usage
```shell
Usage: imessage-cleaner.sh [--no-backup] -a attachment-dir -e extension1 -e extension2 ...

	-a, --attachments-directory dir:
		iMessage attachment directory absolute path.
		Typically in "/User/<username>/Library/Messages/Attachments"
	-e, --extension ext:
		Extension of files to remove. Ex: -e gif
	--no-backup:
		Don't create an archive of removed files.
```

## Restoring backups
* Open a terminal and navigate to your root directory
```shell
cd /
tar -xzf <backup file name>.tar.gz
```

## Future Features
* Sticker removal
* Remove by date and size
* Manager - protect certain files
