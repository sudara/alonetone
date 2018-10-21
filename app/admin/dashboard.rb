ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Comments" do
          table_for Comment.recent.limit(10) do
            column("Id") { |comment| comment.id }
            column("Text") { |comment| comment.body }
            column("Spam") { |comment| comment.is_spam }
          end
        end
      end
    end
  end # content
end
