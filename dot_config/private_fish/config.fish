if status is-interactive
    eval (ssh-agent -c) > /dev/null 2>&1
    set SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
    # Commands to run in interactive sessions can go here
end
