# == Schema Information
#
# Table name: entries
#
#  id                 :integer          not null, primary key
#  guid               :string(36)       not null
#  title              :string(255)      not null
#  search_text        :string(255)
#  encrypted_username :string(255)
#  encrypted_password :string(255)
#  encrypted_url      :string(255)
#  encrypted_notes    :text
#  attachment_uid     :string(255)
#  attachment_name    :string(255)
#  expiration         :datetime
#  project_id         :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class Entry < ActiveRecord::Base

  # Concerns
  include Guidable

  # attr_encrypted :username, key: Settings.entry.username
  # attr_encrypted :password, key: Settings.entry.password
  # attr_encrypted :url, key: Settings.entry.url
  # attr_encrypted :notes, key: Settings.entry.notes

  belongs_to :project

  validates :title, :project, presence: true

  delegate :name, :guid, to: :project, prefix: true

  attr_accessor :can_edit

  private
    def set_search_text
      self.search_text = "#{self.project_name} #{self.title}".downcase
    end

  class << self

    def ordered
      order("#{self.table_name}.title")
    end

    def skinny
      select(['id', 'guid', 'title', 'project_id', 'search_text']\
        .collect {|s| "#{self.table_name}.#{s}"}.join(","))
    end
  end
end
