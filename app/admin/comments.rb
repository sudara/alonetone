ActiveAdmin.register Comment, as: "UserComment" do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#

  menu priority: 2, label: proc{ I18n.t("active_admin.dashboard") }
  config.batch_actions = true

  filter :is_spam

  permit_params :id, :body, :commentable_type, :is_spam

  index do
    selectable_column
    id_column
    column :body
    column :is_spam
    actions
  end
end