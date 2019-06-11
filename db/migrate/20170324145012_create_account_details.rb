class CreateAccountDetails < ActiveRecord::Migration
  def migrate(direction)
    self.send(direction)
  end

  def self.up
    execute(
      "CREATE TABLE `issues` (
      `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
      `description` varchar(20) DEFAULT NULL,
      `priority` integer(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `submitted_by` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
      `created_at` datetime NOT NULL,
      `updated_at` datetime NOT NULL,
      PRIMARY KEY (`id`)) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;"
    )

    add_index :issues, [:updated_at], name: "issues_updated_at"
  end

  def self.down
    drop_table :account_details
  end
end
