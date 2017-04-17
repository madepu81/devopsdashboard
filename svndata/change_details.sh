#!/bin/bash
export TZ="GST+8"
platform="$1"
START_DATE="$2"
END_DATE="$3"
SVN_URL="$4"
OUT=change_details_${platform}_${START_DATE}_${END_DATE}.txt
./change_detail_cq.pl $START_DATE $END_DATE ${SVN_URL}/${platform} -no_header > $OUT
unix2dos $OUT
perl -pi -e "s| -0800| PDT|g;s|\/branches\/${branch}||g" $OUT
