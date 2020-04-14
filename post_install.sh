#!/bin/bash

ARGUMENT_LIST=(
    "timezone"
)

# read arguments
opts=$(getopt \
    --longoptions "$(printf "%s:," "${ARGUMENT_LIST[@]}")" \
    --name "$(basename "$0")" \
    --options "" \
    -- "$@"
)

eval set --$opts

while [[ $# -gt 0 ]]; do
    case "$1" in
        --timezone)
            TZ=$2
            shift 2
            ;;

        *)
            break
            ;;
    esac
done

# Configure SGE
wget -qO- https://raw.githubusercontent.com/bintriz/bsmn-aws-setup/master/configure_sge.sh |bash

# Add users
wget -qO- https://raw.githubusercontent.com/bintriz/bsmn-aws-setup/master/add_user.sh |bash

# Installing packages
yum -y update
yum -y install libcurl-devel gsl-devel # for compiling bcftools
yum -y install readline-devel sqlite-devel # for compiling python
yum -y install gcc72-c++ libXpm-devel xauth # for compiling root
yum -y install gd gd-devel # gd library for GD perl module
yum -y install glib2-devel # for compiling exonerate
yum -y install tmux parallel emacs # etc

# Fix the location of omp.h.
ln -s /usr/lib/gcc/x86_64-amazon-linux/4.8.5/include/omp.h /usr/local/include/

# Timezone
ZONEINFO=$(find /usr/share/zoneinfo -type f|sed 's|/usr/share/zoneinfo/||') 
if [[ ! -z "$TZ" ]] && [[ $ZONEINFO =~ (^|[[:space:]])"$TZ"($|[[:space:]]) ]]; then
    sed -i '/ZONE/s|UTC|'$TZ'|' /etc/sysconfig/clock
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime
fi

# add Taejeong's public key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyo3vT0OLM+zROLs2/BWz1u/roZi6tIAJACjc/q8BIsvH4LLzABBSZ12iZlUxInueo/XuYz3NavDuzesKp9Uc0+aQJAR6oi5j043PZ+z2DMON3Zafjdf2kyBNeXZR3AWbAhM1jPQq69Y5CY21vI7JohSXbnzYfOr8KeySRldh/sV42lTUMrBeQM/92ewnQQ5w5W7ZvbxSjrZ84ukVbMAj1fzz5wH/Wk5oR60Upu8IA+M25pyev3KkXwF3/y9rRkubXFAjg5oUKMELb08TnjtvgMmL5XO0of8dru6futwce7Ix629o86FN5YFe1LQ1qv+B0tcjyOzw/NvrbCthQPoHD tj-macbook" >> ~/.ssh/authorized_keys
