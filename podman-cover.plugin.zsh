podman() {
  if [[ "$1" == "images" ]]; then
    shift

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
      max_repo = length("REPOSITORY")
      max_tag  = length("TAG")
      max_id   = length("IMAGE ID")
      max_size = length("SIZE")
      max_full = length("FULL_REPO")
    }

    {
      full_repo = $1

      # 简化仓库名：始终只取最后一段
      n = split($1, parts, "/")
      repo = parts[n]

      if (length(repo)        > max_repo) max_repo = length(repo)
      if (length($2)          > max_tag)  max_tag  = length($2)
      if (length($3)          > max_id)   max_id   = length($3)
      if (length(fix_size($4))> max_size) max_size = length(fix_size($4))
      if (length(full_repo)   > max_full) max_full = length(full_repo)

      repolist[NR]  = repo
      taglist[NR]   = $2
      idlist[NR]    = $3
      sizelist[NR]  = fix_size($4)
      fulllist[NR]  = full_repo
    }

    END {
      printf "%-*s  %-*s  %-*s  %-*s  %-*s\n",
        max_repo, "REPOSITORY",
        max_tag,  "TAG",
        max_id,   "IMAGE ID",
        max_size, "SIZE",
        max_full, "FULL_REPO"

      line = ""
      for (i = 1; i <= max_repo; i++) line = line "-"
      line = line "  "
      for (i = 1; i <= max_tag; i++) line = line "-"
      line = line "  "
      for (i = 1; i <= max_id; i++) line = line "-"
      line = line "  "
      for (i = 1; i <= max_size; i++) line = line "-"
      line = line "  "
      for (i = 1; i <= max_full; i++) line = line "-"
      print line

      for (i = 1; i <= NR; i++) {
        printf "%-*s  %-*s  %-*s  %-*s  %-*s\n",
          max_repo, repolist[i],
          max_tag,  taglist[i],
          max_id,   idlist[i],
          max_size, sizelist[i],
          max_full, fulllist[i]
      }
    }'
  else
    command podman "$@"
  fi
}
