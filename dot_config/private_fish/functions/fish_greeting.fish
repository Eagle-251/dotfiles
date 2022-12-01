# function fish_greeting
#     source ~/.prompt/temp
#     source ~/.prompt/weather

#     set time (set_color yellow; date +%T;set_color normal) 
#     

#     function getWeather
#         curl -s 'wttr.in/?format=%C'
#     end

#     #function parse_temp
#         #set raw_temp (curl -s 'wttr.in/?format=%t')
#         #if test (echo $raw_temp | sed 's/+//;s/°C//') -lt 12
#             #echo (set_color blue; echo $raw_temp; set_color normal)
#         #else
#             #echo (set_color red; echo $raw_temp; set_color normal)
#         #end
#     #end
#     
#     if  echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1
#         echo Hello $USER, it is "$time" and outside it is "$temp" and "$weather" 
#     else
#         echo -e Hello $USER, it is $time \n --- \n Internet and/or DNS is out.. 
#     end
# end
function fish_greeting
    echo "temp fix"
end
