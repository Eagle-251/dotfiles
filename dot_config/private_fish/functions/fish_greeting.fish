function fish_greeting
    set time (set_color yellow; date +%T;set_color normal) 
    set weather (curl -s 'wttr.in/?format=%C')
    function parse_temp
        set raw_temp (curl -s 'wttr.in/?format=%t')
        if test (echo $raw_temp | sed 's/+//;s/°C//') -lt 12
            echo (set_color blue; echo $raw_temp; set_color normal)
        else
            echo (set_color red; echo $raw_temp; set_color normal)
        end
    end
    echo Hello $USER, it is $timeand outside it is (parse_temp)and $weather
end
