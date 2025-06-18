configs:
  params:
    server.insecure: ${server_insecure}

  cm:
    logoutRedirectURL: ${host}
    url: ${host}
    accounts.github-actions: apiKey
    accounts.terraform: apiKey
    dex.config: |
      connectors:
        - type: github
          id: github
          name: GitHub
          config:
            clientID: $dexGitHubClientID
            clientSecret: $dexGitHubClientSecret
            orgs:
            - name: tattoo-courses

    resource.customizations: |
      argoproj.io/Rollout:
        health.lua: |
          hs = {}
          hs.status = "Healthy"
          hs.message = ""
          return hs

  rbac:
    policy.csv: |
      p, role:github-actions, applications, get, */*, allow
      p, role:github-actions, applications, create, */*, allow
      p, role:github-actions, applications, update, */*, allow
      p, role:github-actions, applications, delete, */*, allow
      p, role:github-actions, applications, sync, */*, allow
      p, role:github-actions, projects, get, */*, allow
      p, role:github-actions, clusters, get, */*, allow
      p, role:github-actions, repositories, get, */*, allow
      g, github-actions, role:github-actions
      g, tattoo-courses:admin, role:admin
      g, tattoo-courses:frontend, role:readonly
      g, terraform, role:admin