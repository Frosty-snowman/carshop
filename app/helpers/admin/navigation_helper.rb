module Admin
  module NavigationHelper
    def admin_nav_link(label, path, icon: nil)
      active = current_page?(path) || (path == admin_root_path && controller_name == "dashboard")
      base = "flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm font-medium transition-all"
      classes = active ? "#{base} bg-violet-600 text-white shadow-md" : "#{base} text-slate-400 hover:bg-white/5 hover:text-white"

      link_to path, class: classes do
        safe_join([ content_tag(:span, icon, class: "text-base w-5 text-center"), label ])
      end
    end
  end
end
