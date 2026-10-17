sync:
	sudo rsync -a --delete salt/ /srv/salt/ && sudo rsync -a --delete pillar/ /srv/pillar/
apply: sync
	sudo salt 'web*' state.apply nginx
test: sync
	sudo salt 'web*' state.apply nginx test=True
ping:
	sudo salt '*' test.ping
