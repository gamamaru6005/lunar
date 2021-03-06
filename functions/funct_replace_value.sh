# funct_replace_value
#
# Replace a value in a file with the correct value
#
# As there is no interactive sed on Solaris, ie sed -i
# pipe through sed to a temporary file, then replace original file
# Some handling is added to replace / when searching so sed works
#
# check_file    = File to replace value in
# check_value   = Value to check for
# correct_value = What the value should be
# position      = Position of value in the line
#.

funct_replace_value () {
  check_file=$1
  check_value=$2
  new_check_value="$check_value"
  correct_value=$3
  new_correct_value="$correct_value"
  position=$4
  if [ "$position" = "start" ]; then
    position="^"
  else
    position=""
  fi
  string_check=`expr "$check_value" : "\/"`
  if [ "$string_check" = 1 ]; then
    new_check_value=`echo "$check_value" |sed 's,/,\\\/,g'`
  fi
  string_check=`expr "$correct_value" : "\/"`
  if [ "$string_check" = 1 ]; then
    new_correct_value=`echo "$correct_value" |sed 's,/,\\\/,g'`
  fi
  new_check_value="$position$new_check_value"
  if [ "$audit_mode" != 2 ]; then
    echo "Checking:  File $check_file contains \"$correct_value\" rather than \"$check_value\""
  fi
  if [ -f "$check_file" ]; then
    check_dfs=`cat $check_file |grep "$new_check_value" |wc -l |sed "s/ //g"`
  fi
  if [ "$check_dfs" != 0 ]; then
    if [ "$audit_mode" != 2 ]; then
      if [ "$audit_mode" = 1 ]; then
        insecure=`expr $insecure + 1`
        echo "Warning:   File $check_file contains \"$check_value\" rather than \"$correct_value\" [$insecure Warnings]"
        funct_verbose_message "" fix
        funct_verbose_message "sed -e \"s/$new_check_value/$new_correct_value/\" < $check_file > $temp_file" fix
        funct_verbose_message "cp $temp_file $check_file" fix
        funct_verbose_message "" fix
      fi
      if [ "$audit_mode" = 0 ]; then
        funct_backup_file $check_file
        echo "Setting:   Share entries in $check_file to be secure"
        sed -e "s/$new_check_value/$new_correct_value/" < $check_file > $temp_file
        cp $temp_file $check_file
        if [ "$os_version" != "11" ]; then
          pkgchk -f -n -p $check_file 2> /dev/null
        else
          pkg fix `pkg search $check_file |grep pkg |awk '{print $4}'`
        fi
        rm $temp_file
      fi
    else
      if [ "$audit_mode" = 2 ]; then
        funct_restore_file $check_file $restore_dir
      fi
    fi
  else
    if [ "$audit_mode" = 1 ]; then
      secure=`expr $secure + 1`
      echo "Secure:    File $check_file contains \"$correct_value\" rather than \"$check_value\" [$secure Passes]"
    fi
  fi
}
