# Class journey

Clicking **Classes** in the left menu opens the class journey: an overview of the whole
course. It shows a roadmap of all classes and a card for every class.

## What students see

- **Journey roadmap:** the current class ("Class 3 of 14"), a progress bar of held
  classes, and one chip per class. The roadmap scrolls so the current class is visible.
- **Class cards:** a cover image, date, title, short description and status. Released
  classes open their class page. Unreleased classes are blurred and locked.

A class card shows one of these states:

| State          | Meaning                                              |
|----------------|------------------------------------------------------|
| Happening now  | The lecture is running (start time plus 200 minutes) |
| Class finished | The lecture is over                                  |
| Upcoming       | The class has not started yet                        |
| Locked         | The class is not released yet                        |

## Releasing classes

Class folders whose names start with `ignore-` are shown as locked cards. The dashboard
reads only their `id`, `name`, `description` and `starting_time`. It does not offer their
environment, Google Doc or recording, and a locked class has no class page. A locked
folder with an incomplete `meta.json` is skipped with a warning instead of stopping the
dashboard.

To release a class, rename the folder, for example `ignore-class03` to `class03`, and
restart SCL.

## Cover images

Put an optional `cover.jpg` in the class folder. The dashboard serves it at
`/api/classes/<class-id>/cover`. Use a 16:9 image about 800 pixels wide to keep the
repository small. Classes without a cover show a plain coloured header.

## Tests

The tests use temporary databases and class folders; no lab containers are started:

```bash
python -m unittest discover -s tests -p 'test_journey.py'
```
