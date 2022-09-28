function nativefier
    docker run --rm --user root:root -w /target/  -v ~/nativefier:/target/ nativefier/nativefier $argv 
end
