podman() {
  if [[ "$1" == "images" ]]; then
    shift

    # 使用 format 输出四列：Repository, Tag, ID, Size
    command podman images --format "{{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}" | \
    awk '
    function fix_size(s) {
      if (s ~ /^[0-9]+(\.[0-9]+)?$/) {
        return s " MB"
      } else if (s ~ /^[0-9]+(\.[0-9]+)? [MG]B$/) {
        return s
      } else if (s ~ /^[0-9]+(\.[0-9]+)? [KGT]B$/) {
        return s
      }
      return s
    }

    BEGIN {
      FS = "\t"
      # 初始化最大宽度
      max_repo = length("REPOSITORY")
      max_tag  = length("TAG")
      max_id   = length("IMAGE ID")
      max_size = length("SIZE")
    }

    {
      # 简化仓库名
      repo = $1
      gsub(/^docker\.io\/library\//, "", repo)
      gsub(/^docker\.io\//, "", repo)

      # 更新最大宽度
      if (length(repo)    > max_repo) max_repo = length(repo)
      if (length($2)      > max_tag)  max_tag  = length($2)
      if (length($3)      > max_id)   max_id   = length($3)
      if (length(fix_size($4)) > max_size) max_size = length(fix_size($4))

      # 存储数据
      repolist[NR] = repo
      taglist[NR]  = $2
      idlist[NR]   = $3
      sizelist[NR] = fix_size($4)
    }

    END {
      # 打印表头（左对齐）
      printf "%-*s  %-*s  %-*s  %-*s\n",
        max_repo, "REPOSITORY",
        max_tag,  "TAG",
        max_id,   "IMAGE ID",
        max_size, "SIZE"

      # 构造分隔线（严格对齐）
      line = ""
      for (i = 1; i <= max_repo; i++) line = line "-"
      line = line "  "
      for (i = 1; i <= max_tag; i++) line = line "-"
      line = line "  "
      for (i = 1; i <= max_id; i++) line = line "-"
      line = line "  "
      for (i = 1; i <= max_size; i++) line = line "-"
      print line

      # 打印数据行
      for (i = 1; i <= NR; i++) {
        printf "%-*s  %-*s  %-*s  %-*s\n",
          max_repo, repolist[i],
          max_tag,  taglist[i],
          max_id,   idlist[i],
          max_size, sizelist[i]
      }
    }'
  else
    command podman "$@"
  fi
}

