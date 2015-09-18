# encoding: utf-8

##
# Backup Generated: forest_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t forest_backup [-c <path_to_configuration_file>]
#
secrets_file_path = 'config/secrets.yml'
db_file_path = 'config/database.yml'
prd_db = YAML.load(File.open(db_file_path))['production']
backup = YAML.load(File.open(secrets_file_path))['production']['backup']

Backup::Model.new(:passkeep_backup, 'Backup for passkeep.bbox.ly - database') do
  ##
  # Split [Splitter]
  #
  # Split the backup file in to chunks of 250 megabytes
  # if the backup file size exceeds 250 megabytes
  #
  split_into_chunks_of 250
  ##
  # Archive [Archive]
  #
  # Adding a file or directory (including sub-directories):
  #   archive.add "/path/to/a/file.rb"
  #   archive.add "/path/to/a/directory/"
  #
  # Excluding a file or directory (including sub-directories):
  #   archive.exclude "/path/to/an/excluded_file.rb"
  #   archive.exclude "/path/to/an/excluded_directory
  #
  # By default, relative paths will be relative to the directory
  # where `backup perform` is executed, and they will be expanded
  # to the root of the filesystem when added to the archive.
  #
  # If a `root` path is set, relative paths will be relative to the
  # given `root` path and will not be expanded when added to the archive.
  #
  #   archive.root '/path/to/archive/root'
  #
  # For more details, please see:
  # https://github.com/meskyanichi/backup/wiki/Archives
  #
  # archive :media do |archive|
  #   # Run the `tar` command using `sudo`
  #   # archive.use_sudo
  #   archive.add "/var/www/laskerfoundation.org/shared/media"
  #   archive.tar_options '--listed-incremental=/var/www/laskerfoundation.org/shared/incremental_backup_manifest'
  # end

  ##
  # PostgreSQL [Database]
  #
  database PostgreSQL do |db|
    db.name               = prd_db['database']
    db.username           = prd_db['username']
    db.password           = prd_db['password']
    db.host               = prd_db['host'] if prd_db['host']
    db.port               = prd_db['port'] if prd_db['port']
    #db.socket             = "/tmp/pg.sock"
    #db.skip_tables        = ["skip", "these", "tables"]
    #db.only_tables        = ["only", "these", "tables"]
    db.additional_options = ["-Ox"]
  end

  ##
  # Amazon Simple Storage Service [Storage]
  #
  # Available Regions:
  #
  #  - ap-northeast-1
  #  - ap-southeast-1
  #  - eu-west-1
  #  - us-east-1
  #  - us-west-1
  #
  store_with S3 do |s3|
    s3.access_key_id     = backup['aws']['key_id']
    s3.secret_access_key = backup['aws']['secret_key']
    s3.region            = backup['s3']['region']
    s3.bucket            = backup['s3']['bucket']
    s3.path              = backup['s3']['path']
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

  ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the Wiki for other delivery options.
  # https://github.com/meskyanichi/backup/wiki/Notifiers
  #
  notify_by Ses do |ses|
    ses.on_success           = false
    ses.on_warning           = true
    ses.on_failure           = true

    ses.access_key_id        = backup['aws']['key_id']
    ses.secret_access_key    = backup['aws']['secret_key']
    ses.region               = backup['s3']['region']
    ses.from                 = backup['email']['from']
    ses.to                   = backup['email']['to']
  end

end
