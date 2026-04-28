# Portfolio

A static portfolio/blog site built with `blogatto` and `lustre`.

The idea is to largely base the website off of one that I found
[here](https://jekyll-theme-minimal-resume.netlify.app/)

# Ideas

## Landing page

Creative landing spot
- [ ] Accessibility options to disable creative coding stuff (disable)

Should link out to the rest of the pages easily
- [ ] Have a static nav bar between each section
- [ ] Have some highlights of each (blogs, about, events)

## Resume page

Important to have a downloadable version of this too

- [ ] Brief about
- [ ] Work experience (history tree)
    - Timelines
    - Brief about
    - Key tech
    - Key roles
- [ ] Volunteer experience
    - SDC events
    - Byte Club
- [ ] Schooling

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

With any post
- Context is important! Add it where you can
- Always link out to references used in the research of the post
- Have a quick TL;DR at the top with a summary
- Try to avoid HUGE chunks of text and code
- Don't throw in images for the sake of images

Ideas around interaction/visuals
- Any concept that can be explained visually should be explained visually

# Main Page

- [ ] Link Tree
    - [ ] Each bubble should react when the user hovers over it
- [ ] Work Experience
    - [ ] Timeline view (which is just a stylized list)
    - [ ] Link to every office that you've worked at
    - [ ] Link to every project if there's a product link
    - [ ] Garmin
        - [ ] Summer Student (BLE team)
        - [ ] Internship (fatcat, rally ble revamp)
        - [ ] Full time (helios & spek)
    - [ ] Lockheed Skunkworks
        - [ ] Platform team
        - [ ] Martian team
        - [ ] Devops team
    - [ ] Big Geo!!!
    - Reverse chronological order
- [ ] Side Projects
    - [ ] Cards for each
        - Gif demo of each or just a little picture (it would be sweet if the gif would play when you hover over it)
        - Link to the github repo
        - Little language styles at the bottom
        - Description of what it is
        - A little indicator whether it's a WIP
    - [ ] Git repo needs to be split from the collection repos that you have
    - [ ] Shout out byte club somewhere
    - [ ] Include this website
    - [ ] Beat generator CLI
    - [ ] Creative coding stuff
    - [ ] Some of your graphics stuff from university

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
