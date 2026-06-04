#!/usr/bin/env bash
set -euo pipefail

tmp_dir="$(mktemp -d)"
giscus_override="${tmp_dir}/giscus-test-override.yml"
disqus_override="${tmp_dir}/disqus-test-override.yml"
giscus_site="${tmp_dir}/giscus-site"
disqus_site="${tmp_dir}/disqus-site"
giscus_fixture="_posts/2024-01-01-comments-giscus-fixture.md"
disqus_fixture="_posts/2024-01-02-comments-disqus-fixture.md"

cleanup() {
  rm -f "${giscus_fixture}" "${disqus_fixture}"
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

if [ -e "${giscus_fixture}" ] || [ -e "${disqus_fixture}" ]; then
  echo "comments integration fixture path already exists in _posts" >&2
  exit 1
fi

cat >"${giscus_fixture}" <<'MARKDOWN'
---
layout: post
title: comments giscus fixture
date: 2024-01-01
description: Fixture post for giscus integration testing.
comments: true
giscus_comments: true
related_posts: false
---

Fixture content.
MARKDOWN

cat >"${disqus_fixture}" <<'MARKDOWN'
---
layout: post
title: comments disqus fixture
date: 2024-01-02
description: Fixture post for disqus integration testing.
comments: true
disqus_comments: true
related_posts: false
---

Fixture content.
MARKDOWN

cat >"${giscus_override}" <<'YAML'
disqus_shortname: false
giscus:
  repo: alshedivat/al-folio
  repo_id: R_kgDOExample
  category: Comments
  category_id: DIC_kwDOExample
YAML

cat >"${disqus_override}" <<'YAML'
disqus_shortname: al-folio
giscus:
  repo:
  repo_id:
  category:
  category_id:
YAML

bundle exec jekyll build --config "_config.yml,${giscus_override}" -d "${giscus_site}" >/dev/null
bundle exec jekyll build --config "_config.yml,${disqus_override}" -d "${disqus_site}" >/dev/null

giscus_page="${giscus_site}/blog/2024/comments-giscus-fixture/index.html"
disqus_page="${disqus_site}/blog/2024/comments-disqus-fixture/index.html"

if [ ! -f "${giscus_page}" ]; then
  echo "giscus fixture page was not generated at ${giscus_page}" >&2
  exit 1
fi

if [ ! -f "${disqus_page}" ]; then
  echo "disqus fixture page was not generated at ${disqus_page}" >&2
  exit 1
fi

grep -q 'https://giscus.app/client.js' "${giscus_page}"
if grep -q 'giscus comments misconfigured' "${giscus_page}"; then
  echo "unexpected giscus misconfiguration warning in ${giscus_page}" >&2
  exit 1
fi

grep -q 'id="disqus_thread"' "${disqus_page}"
grep -q '.disqus.com/embed.js' "${disqus_page}"

echo "comments integration checks passed"
