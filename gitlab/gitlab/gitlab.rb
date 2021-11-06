# 根据实际情况修改域名
external_url 'https://gitlab.example.net'
gitlab_rails['gitlab_ssh_host'] = 'gitlab.example.net'

# ssh端口
gitlab_rails['gitlab_shell_ssh_port'] = 1022

# email配置, 可不配置
gitlab_rails['gitlab_email_from'] = 'gitlab@example.net'
gitlab_rails['gitlab_email_display_name'] = 'Gitlab'
gitlab_rails['gitlab_email_reply_to'] = 'gitlab@example.net'
gitlab_rails['gitlab_email_subject_suffix'] = ''
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "mail.example.net"
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = "gitlab@example.net"
gitlab_rails['smtp_password'] = "Gitlab"
gitlab_rails['smtp_domain'] = "mail.example.net"
gitlab_rails['smtp_authentication'] = "plain"
gitlab_rails['smtp_enable_starttls_auto'] = true

# nginx配置
nginx['client_max_body_size'] = '250m'
nginx['listen_port'] = 80
nginx['listen_https'] = false
