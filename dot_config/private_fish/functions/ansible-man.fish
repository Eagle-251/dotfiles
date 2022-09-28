function ansible-man
ansible-doc (ansible-doc --list | fzf | awk '{ print $1}')
end
