class CreateMassInviteSignups < ActiveRecord::Migration[6.1]
  def change
    create_table :mass_invite_signups do |t|
      t.references :user
      t.references :mass_invite
    end
  end
end
