add_header_proc do
  %Q|\t<link rel="alternate" type="application/atom+xml" title="Atom#{h @conf.title}" href="#{h @conf.base_url}recent.atom">\n|
end
