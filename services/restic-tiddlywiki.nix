{ config, lib, pkgs, inputs, ...}:
{
	restic.backups = {
		remotebackup = {
			# In this case, the repo already exists. Otherwise, we would set it to true;
			initialize = false;
			paths = [
				config.services.tw-knowledge-store.dataDir
				config.services.tw-haskell.dataDir
				config.services.tw-rust.dataDir
			];
			repository = "s3:fra1.digitaloceanspaces.com/knowledge-db-backups";
			passwordFile = config.sops.secrets.restic_pass.path;
			environmentFile = config.sops.secrets.digitalocean_spaces_credentials.path;
			timerConfig = {
				OnCalendar = "*:00";
			};
			pruneOpts = [
				"--keep-hourly 24"
				"--keep-daily 7"
			];
		};
	};
}