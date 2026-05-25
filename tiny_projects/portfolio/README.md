# Portfolio

A static portfolio/blog site built with `blogatto` and `lustre`.

The idea is to largely base the website off of one that I found
[here](https://jekyll-theme-minimal-resume.netlify.app/)

# Ideas

## Side project garden

- [ ] List of each side project that you're working on sorted by recency
- [ ] Link out to your side project repo
- [ ] Build small demos of each project to showcase (ascii cinema or screen casts?)
- [ ] Tech bubbles for things that are used (language, stack)

## Blog

Goals
- Kind of an "As I Learn It" style blog
- Exploration how things work over tutorials
- Add discussion points to discourse that exists

KISS
- Write about small topics that interest you
- Avoid how tos for simple things
- Try to keep your bundle size tiny (where possible)

Ideas
- [ ] Building software with Buck2 & devenv
- [ ] Building an android app with Rust & Ply
- [ ] Navigating vibe coding while also learning
- [ ] Creative coding articles (replicate Coding Train and others in Rust)
- [ ] Building a DAW in Rust (reference the other Rust articles on this)
- [ ] Commentry on videos that you watch
- [ ] Random research topics
- [ ] Meta learning from the view point of a musician with programming
- [ ] Linking knowledge together
- [ ] Reaction to [this video](https://www.youtube.com/watch?v=V-ZvAw_VNk4)

With any post
- Context is important! Add it where you can
- Always link out to references used in the research of the post
- Have a quick TL;DR at the top with a summary
- Try to avoid HUGE chunks of text and code
- Don't throw in images for the sake of images

Ideas around interaction/visuals
- Any concept that can be explained visually should be explained visually

# Notes

## Theming and CSS

Most themes are based on some CSS variables that change when you set a particular
class or attribute on an element. Then everything else responds to that particular
change.

[Reference for design thoughts](https://www.youtube.com/watch?v=JbxKTBvSLeY)

So building this out will be to create
- Some basic design tokens
- Basic design components that reference the design tokens
- Build the pages out of the components
