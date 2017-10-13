{% if theme.gitalk.enable %}
   {% set owner = theme.gitalk.githubID %}
   {% set repo = theme.gitalk.repo %}
   {% set cid = theme.gitalk.ClientID %}
   {% set adminUser = "dmego" %}
   {% set cs = theme.gitalk.ClientSecret %}
  <link rel="stylesheet" href="https://unpkg.com/gitalk/dist/gitalk.css">
  <script src="https://unpkg.com/gitalk/dist/gitalk.min.js"></script>
   <script type="text/javascript">
        var gitalk = new Gitalk({
          clientID: '{{cid}}',
          clientSecret: '{{cs}}',
          repo: '{{repo}}',
          owner: '{{owner}}',
          admin: ['{{adminUser}}'],
          id: location.pathname,
		  		distractionFreeMode: true
        })
        gitalk.render('gitalk-container')
       </script>
{% endif %}
