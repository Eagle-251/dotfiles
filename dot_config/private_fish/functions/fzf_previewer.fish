function fzf_previewer -d 'generate preview for completion widget.
    argv[1] is the currently selected candidate in fzf
    argv[2] is a string containing the rest of the output produced by `complete -Ccmd`
    '

    if test "$argv[2]" = "Redefine variable"
        # show environment variables current value
        set -l evar (echo $argv[1] | cut -d= -f1)
        echo $argv[1]$$evar
    else
        echo $argv[1]
    end

    set -l path (string replace "~" $HOME -- $argv[1])

    # previwer for different file/dir types
    set -l MIMETYPE (file --dereference --brief --mime-type -- $path)
    switch $MIMETYPE
        case "text*"
            bat --style=rule --color=always --line-range :500 $path
        case "video*" "audio*" "image*"
            mediainfo $path
        case inode/directory
            ls -lhA $path
        case application/x-alpa-package "application/x-*compressed-tar" application/zstd application/zip
            bsdtar --list --file $path
        case application/x-rar
            unrar l -p- -- $path
        case "*"
            echo $path
    end

    # if fish knows about it, let it show info
    type -q "$path" 2>/dev/null; and type -a "$path"

    # show aditional data
    echo $argv[2]
end

