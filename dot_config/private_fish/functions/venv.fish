function venv --wraps='virtualenv (basename /home/ewan/Python/LittleBrother)' --description 'alias venv virtualenv (basename /home/ewan/Python/LittleBrother)'
set dir $PWD
set dirName (basename $dir)   
virtualenv $dirName $argv
source $dirName/bin/activate.fish 
end
