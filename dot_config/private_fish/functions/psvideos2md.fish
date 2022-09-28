function videos2md
  set courseTitle (basename $PWD)
  echo "# $courseTitle"
  for d in (ls -d */)
  echo -e "## $d \n" | sed "s|/||;s|[0-9]||g;s|\.||g"
  for i in (ls $d/*.mp4)
  set title (echo $i | sed "s|.mp4||" | cut -d "/" -f 2)
  echo -e "### $title \n"
  echo -e "<video src=\"file://$PWD/$i\" controls></video> \n"
  end
  end
end
