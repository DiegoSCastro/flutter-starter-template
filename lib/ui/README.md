# UI (`ui`)

The app's **design system**: generic, non-business visual building blocks shared
across features. Like `core/`, it carries no business meaning and **must never
depend on `features/`**. Dependency direction is `features → ui → core`
(`ui` may use `core` infrastructure such as extensions, layout, and media).

## Directory Structure

- **`theme/`**: Global theming — color palettes, typography, spacing/radius/icon
  tokens, `ThemeData`, and theme switching logic (`ThemeBloc`).
- **`widgets/`**: Reusable UI components that are entirely generic and not tied
  to any feature (buttons, loading/empty/error views, scaffolds, media viewers).
- **`animation/`**: Reusable durations and implicitly-animated widget helpers.

## Why separate from `core/`?

`core/` is non-visual cross-cutting infrastructure (network, DI, analytics,
notifications). The design system is large and self-contained, so it lives in
its own top-level area to keep `core/` focused on plumbing.
