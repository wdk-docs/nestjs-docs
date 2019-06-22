for md in $(find . -name '*.md'); do
    echo $md;
    pandoc --from=markdown --to=rst --output=$(dirname $md)/$(basename ${md/.md/}).rst $md;
    rm -rf $md; # 删除
    #echo "${md/.md/}"; # 替换空
    #mv $md ${md/.md/}; # 改名
done
