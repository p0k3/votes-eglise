class Campaign < ActiveRecord::Base

  belongs_to :structure
  has_many :motions, dependent: :destroy
  accepts_nested_attributes_for :motions, reject_if: :all_blank, allow_destroy: true

  delegate :name, to: :structure, prefix: true

  validates :name, presence: true

  def period
    "Du #{I18n.l self.start_at} au #{I18n.l self.end_at}"
  end
  def motions_count
    motions.count
  end

  def has_already_vote? elector
    b = false
    motions.each do |motion|
      if motion.has_voted? elector
        b = true
      end
    end
    b
  end

  def elector_can_vote? elector
    (elector && self.is_public && Time.now.between?(start_at, end_at) && !has_already_vote?(elector)) || (elector && elector.can_vote && Time.now.between?(start_at, end_at) && !has_already_vote?(elector))
  end

  def get_elector_note elector
    unless elector.blank?
      if !elector.can_vote
        elector.note
      elsif !Time.now.between?(start_at, end_at)
        "Les votes de cette campagne ne sont pas ouverts. Période de vote : #{self.period}"
      elsif has_already_vote?(elector)
        "Vous avez déjà voté pour cette campagne."
      end
    end
  end

  def self.get_campaigns_for_member user
    electors = user.electors
    Campaign.joins(:structure).where('structure_id IN (?)', electors.pluck(:structure_id)).order('structures.name')
  end
  def self.get_campaigns_for_structure structure
    electors = structure.self_electors
    Campaign.joins(:structure).where('structure_id IN (?)', electors.pluck(:structure_id)).order('structures.name')
  end

  def self.get_campaigns_for_president user
    president_roles = Role.where(name: :president, rolizations:{resource_id: user.id, resource_type: user.get_class}).joins(:rolizations)
    campaigns = []
    president_roles.each do |role|
      structure = role.resource
      campaigns = campaigns+structure.campaigns
    end
    campaigns
  end

  def self.get_public_campaigns user
    Campaign.where(is_public: true).where('ID NOT IN (?)', self.get_campaigns_for_member(user).pluck(:id))
  end

  def self.currents
    Campaign.where('end_at >= ?', Time.now).order('name')
  end

  def get_voters opts=nil
    motion_ids = Motion.where(campaign_id: self.id).pluck(:id)
    if opts[:only_electors] && opts[:only_electors] == true
      Voter.where('motion_id IN (?) AND elector_id IS NOT NULL', motion_ids).group(:elector_id).count.count
    else
      Voter.where('motion_id IN (?) AND elector_id IS NULL', motion_ids).group([:resource_id, :resource_type]).count.count
    end
  end
end
