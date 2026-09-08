window.BLOG_REGISTRY = window.BLOG_REGISTRY || [];
window.BLOG_REGISTRY.push({
  "id": "2026-09-07-understanding-git-and-github",
  "title": "Understanding Git and GitHub",
  "author": "Sukee Parker",
  "date": "2026-09-07",
  "category": "Technology",
  "tags": [],
  "excerpt": "Use Git to save code.",
  "content": "<p>Git, a distributed version-control system, solves the problem of accidental deletions by providing snapshots of development work. Essentially, it acts as<b> a time machine for your code</b>, enabling developers to view changes, revert to earlier versions, and experiment without disrupting the working code.&nbsp;&nbsp;Its core mental model is simple: <b>Edit → Stage → Commit.</b> A working directory contains your current changes, staging determines what goes into the next snapshot, and a commit permanently records that snapshot in the repository.</p><p>Branches make experimentation safe. You can create a separate branch for a feature, bug fix, or experiment while leaving the main code untouched. Once the work is ready, you merge it back. If multiple developers change the same code, Git identifies the conflict and asks you to decide which version should remain.</p><p>Git is the version-control technology; GitHub hosts Git repositories and enables collaboration. Developers push local commits to GitHub, pull changes from others, and use pull requests to review work before merging it into the main branch. A typical professional workflow is <b>Pull → Create Branch → Build → Stage → Commit → Push → Pull Request → Review → Merge.</b></p><p>This becomes even more important with GenAI doing more of the coding. An AI agent can generate a feature or modify many files very quickly, but Git gives us a record of exactly what changed and the ability to reject or undo those changes. The modern workflow increasingly becomes Human Intent → GenAI → Code Changes → Git → Review &amp; Test → GitHub → Production. AI can do more of the implementation, while humans increasingly focus on reviewing, testing, approving, and deciding what should become part of the real product.</p><div class=\"yt-embed\"><iframe src=\"https://www.youtube.com/embed/s3UVVkmyS78\" title=\"YouTube video\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\" allowfullscreen=\"\"></iframe></div>",
  "contentType": "html",
  "autoRead": false,
  "pinned": false,
  "showHome": true
});
